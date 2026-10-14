package com.server.backend.controller.Admission;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.server.backend.DTO.Call_Letter_DTO;
import com.server.backend.DTO.Call_Letter_Print_DTO;
import com.server.backend.service.Admission.Call_Letter_Print_Service;
import com.server.backend.service.Admission.Call_Letter_Service;

@RestController
@RequestMapping("/admission")
public class Call_Letter_Controller {

    private final Call_Letter_Service service;
    private final Call_Letter_Print_Service printService;

    public Call_Letter_Controller(
            Call_Letter_Service service,
            Call_Letter_Print_Service printService) {

        this.service = service;
        this.printService = printService;
    }

    @GetMapping("/call-letter")
    public List<Call_Letter_DTO> getCallLetterData(
            @RequestParam String rank,
            @RequestParam String caste) {

        return service.getCallLetterData(
                rank,
                caste);
    }

    /**
     * Printable call letter. Either single mode ({@code regid}) or bulk mode
     * ({@code fromRank}/{@code toRank}/{@code caste}), always scoped to {@code distCode}.
     * Returns the letterhead/fee block once plus the list of candidate letters.
     */
    @GetMapping("/call-letter/print")
    public Call_Letter_Print_DTO getCallLetterPrint(
            @RequestParam String distCode,
            @RequestParam(name = "regid", required = false) String regid,
            @RequestParam(name = "fromRank", required = false) String fromRank,
            @RequestParam(name = "toRank", required = false) String toRank,
            @RequestParam(name = "caste", required = false) String caste) {

        return printService.getCallLetterPrint(
                distCode,
                regid,
                fromRank,
                toRank,
                caste);
    }
}
