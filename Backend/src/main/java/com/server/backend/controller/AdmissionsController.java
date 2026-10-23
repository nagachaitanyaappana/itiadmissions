package com.server.backend.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

@Controller
@RequestMapping("/admissions")
public class AdmissionsController {

    @GetMapping("/print-admission-slip")
    public ModelAndView printAdmissionSlip() {
        ModelAndView mv = new ModelAndView("checkmeritschedule/admissionIntialization");
        return mv;
    }
}
