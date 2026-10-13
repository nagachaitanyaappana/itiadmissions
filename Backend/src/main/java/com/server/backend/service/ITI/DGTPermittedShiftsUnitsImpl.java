package com.server.backend.service.ITI;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.server.backend.DTO.ShiftUnitEntryDto;
import com.server.backend.DTO.ShiftUnitPermittedRequestDto;
import com.server.backend.DTO.ShiftUnitPermittedResponseDto;
import com.server.backend.entity.ShiftUnitPermitted;
import com.server.backend.entity.ShiftUnitPermittedId;
import com.server.backend.Repository.ITI.ShiftUnitPermittedRepository;

@Service
public class DGTPermittedShiftsUnitsImpl implements DGTPermittedShiftsUnits {

    private final ShiftUnitPermittedRepository repository;
    private final NamedParameterJdbcTemplate jdbc;

    public DGTPermittedShiftsUnitsImpl(ShiftUnitPermittedRepository repository,
            NamedParameterJdbcTemplate jdbc) {
        this.repository = repository;
        this.jdbc = jdbc;
    }

    @Override
    @Transactional
    public ShiftUnitPermittedResponseDto save(ShiftUnitPermittedRequestDto dto) {

        // 1. Validate all entries together (including duplicate check)
        validateEntries(dto.getEntries());

        // Strength is not entered on this screen any more: it always mirrors the sanctioned
        // strength recorded against the trade in Add Trade (ititrade.strength), so a permitted
        // shift/unit can never drift out of sync with the trade.
        Integer tradeStrength = lookUpTradeStrength(dto.getItiCode(), dto.getTradeCode());
        if (tradeStrength == null) {
            throw new IllegalArgumentException("Trade " + dto.getTradeCode()
                    + " is not sanctioned for ITI " + dto.getItiCode()
                    + "; add the trade first");
        }

        // 2. Delete all existing records for this ITI + Trade
        repository.deleteByItiCodeAndTradeCode(dto.getItiCode(), dto.getTradeCode());

        // 3. Save each entry
        List<ShiftUnitEntryDto> savedEntries = new ArrayList<>();

        List<ShiftUnitPermitted> entitiesToSave = new ArrayList<>();
        for (ShiftUnitEntryDto entryDto : dto.getEntries()) {
            ShiftUnitPermitted entity = mapToEntity(dto, entryDto, tradeStrength);
            entitiesToSave.add(entity);
        }
        
        List<ShiftUnitPermitted> savedEntities = repository.saveAll(entitiesToSave);
        for (ShiftUnitPermitted savedEntity : savedEntities) {
            savedEntries.add(mapToEntryDto(savedEntity));
        }

        // 4. Build and return response
        return buildResponse(dto, savedEntries, tradeStrength);
    }

    @Override
    @Transactional(readOnly = true)
    public ShiftUnitPermittedResponseDto getByItiAndTrade(
            String itiCode,
            String tradeCode) {

        List<ShiftUnitPermitted> entities = repository.findByItiCodeAndTradeCode(
                itiCode, tradeCode);

        if (entities.isEmpty()) {
            ShiftUnitPermittedResponseDto empty = new ShiftUnitPermittedResponseDto();
            empty.setItiCode(itiCode);
            empty.setTradeCode(tradeCode);
            empty.setTradeStrength(lookUpTradeStrength(itiCode, tradeCode));
            return empty;
        }

        List<ShiftUnitEntryDto> entries = entities.stream()
                .map(this::mapToEntryDto)
                .collect(Collectors.toList());

        ShiftUnitPermittedResponseDto response = new ShiftUnitPermittedResponseDto();
        response.setItiCode(itiCode);
        response.setTradeCode(tradeCode);
        response.setAvailableYear(entities.get(0).getAvailableYear());
        response.setTradeStrength(lookUpTradeStrength(itiCode, tradeCode));
        response.setEntries(entries);

        return response;
    }

    @Override
    @Transactional
    public void delete(String itiCode,
                       String tradeCode,
                       Integer shiftAllowed,
                       Integer unitAllowed) {

        ShiftUnitPermittedId id = new ShiftUnitPermittedId(
                itiCode,
                tradeCode,
                String.valueOf(shiftAllowed),
                String.valueOf(unitAllowed));

        repository.deleteById(id);
    }

    // ---------------- Batch Validation ----------------

    private void validateEntries(List<ShiftUnitEntryDto> entries) {

        if (entries == null || entries.isEmpty()) {
            throw new IllegalArgumentException("At least one entry is required");
        }

        Set<String> seenCombinations = new HashSet<>();

        for (ShiftUnitEntryDto entry : entries) {
            validateEntry(entry);

            String combination = entry.getShiftAllowed() + "-" + entry.getUnitAllowed();

            if (seenCombinations.contains(combination)) {
                throw new IllegalArgumentException(
                        "Duplicate shift and unit combination found: shift " +
                                entry.getShiftAllowed() + ", unit " +
                                entry.getUnitAllowed());
            }

            seenCombinations.add(combination);
        }
    }

    // ---------------- Single Entry Validation ----------------

    private void validateEntry(ShiftUnitEntryDto dto) {

        // Shift: only 1 to 3
        if (dto.getShiftAllowed() == null ||
                dto.getShiftAllowed() < 1 || dto.getShiftAllowed() > 3) {

            throw new IllegalArgumentException(
                    "Shift allowed must be between 1 and 3");
        }

        // Unit: only 1 to 12
        if (dto.getUnitAllowed() == null ||
                dto.getUnitAllowed() < 1 || dto.getUnitAllowed() > 12) {

            throw new IllegalArgumentException(
                    "Unit allowed must be between 1 and 12");
        }

        // Strength vacant: cannot be negative
        if (dto.getStrengthVacant() != null &&
                dto.getStrengthVacant() < 0) {

            throw new IllegalArgumentException(
                    "Strength vacant cannot be negative");
        }
    }

    // ---------------- Mapping ----------------

    private ShiftUnitPermitted mapToEntity(
            ShiftUnitPermittedRequestDto requestDto,
            ShiftUnitEntryDto entryDto,
            Integer tradeStrength) {

        ShiftUnitPermitted entity = new ShiftUnitPermitted();

        entity.setItiCode(requestDto.getItiCode());
        entity.setTradeCode(requestDto.getTradeCode());
        entity.setAvailableYear(requestDto.getAvailableYear());

        entity.setShiftAllowed(String.valueOf(entryDto.getShiftAllowed()));
        entity.setUnitAllowed(String.valueOf(entryDto.getUnitAllowed()));
        // Strength is derived from Add Trade; the entry's value is ignored. Vacant still honours a
        // value the caller sends (so an existing consumed count survives a resave), else defaults
        // to the full strength.
        entity.setStrength(tradeStrength);
        Integer vacant = entryDto.getStrengthVacant();
        entity.setStrengthVacant(vacant != null ? vacant : tradeStrength);

        return entity;
    }

    /** Sanctioned strength recorded for the trade in Add Trade ({@code ititrade.strength}). */
    private Integer lookUpTradeStrength(String itiCode, String tradeCode) {
        if (tradeCode == null || !tradeCode.trim().matches("-?\\d+")) {
            return null;
        }
        List<Integer> rows = jdbc.getJdbcTemplate().queryForList(
                "SELECT strength FROM public.ititrade WHERE iti_code = ? AND trade_code = ?",
                Integer.class, itiCode, Integer.valueOf(tradeCode.trim()));
        return rows.isEmpty() ? null : rows.get(0);
    }

    private ShiftUnitEntryDto mapToEntryDto(ShiftUnitPermitted entity) {

        ShiftUnitEntryDto dto = new ShiftUnitEntryDto();

        dto.setStrength(entity.getStrength());
        dto.setShiftAllowed(Integer.valueOf(entity.getShiftAllowed()));
        dto.setUnitAllowed(Integer.valueOf(entity.getUnitAllowed()));
        dto.setStrengthVacant(entity.getStrengthVacant());

        return dto;
    }

    private ShiftUnitPermittedResponseDto buildResponse(
            ShiftUnitPermittedRequestDto requestDto,
            List<ShiftUnitEntryDto> entries,
            Integer tradeStrength) {

        ShiftUnitPermittedResponseDto response = new ShiftUnitPermittedResponseDto();

        response.setItiCode(requestDto.getItiCode());
        response.setTradeCode(requestDto.getTradeCode());
        response.setAvailableYear(requestDto.getAvailableYear());
        response.setTradeStrength(tradeStrength);
        response.setEntries(entries);

        return response;
    }
}