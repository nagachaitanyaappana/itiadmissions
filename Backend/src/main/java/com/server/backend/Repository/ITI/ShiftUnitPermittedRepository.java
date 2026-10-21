package com.server.backend.Repository.ITI;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.server.backend.entity.ShiftUnitPermitted;
import com.server.backend.entity.ShiftUnitPermittedId;

public interface ShiftUnitPermittedRepository
        extends JpaRepository<ShiftUnitPermitted, ShiftUnitPermittedId> {

    List<ShiftUnitPermitted> findByItiCodeAndTradeCode(
            Integer itiCode,
            Integer tradeCode);

    boolean existsByItiCodeAndTradeCodeAndShiftAllowedAndUnitAllowed(
            Integer itiCode,
            Integer tradeCode,
            String shiftAllowed,
            String unitAllowed);

    
    void deleteByItiCodeAndTradeCode(
            Integer itiCode,
            Integer tradeCode);
}
