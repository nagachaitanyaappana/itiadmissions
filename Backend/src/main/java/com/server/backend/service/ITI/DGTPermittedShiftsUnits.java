package com.server.backend.service.ITI;

import com.server.backend.DTO.ShiftUnitPermittedRequestDto;
import com.server.backend.DTO.ShiftUnitPermittedResponseDto;

public interface DGTPermittedShiftsUnits {

    ShiftUnitPermittedResponseDto save(ShiftUnitPermittedRequestDto dto);

    ShiftUnitPermittedResponseDto getByItiAndTrade(
            Integer itiCode,
            Integer tradeCode);

    void delete(
            Integer itiCode,
            Integer tradeCode,
            Integer shiftAllowed,
            Integer unitAllowed);
}