package com.server.frontend.controller.checkmeritschedulecontroller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class AdmissionPageController {

    // Page view endpoint - accessed via /ScheduleEntry link in navbar
    @GetMapping("/ScheduleEntry")
    public String scheduleEntry(HttpServletRequest request) {
        if (notLoggedIn(request)) {
            return "redirect:/?error=session";
        }
        return "checkmeritschedule/ScheduleEntry";
    }

    // Page view endpoint for deleting schedule entries
    @GetMapping("/DeleteScheduleEntry")
    public String deleteScheduleEntry(HttpServletRequest request) {
        if (notLoggedIn(request)) {
            return "redirect:/?error=session";
        }
        return "checkmeritschedule/deleteScheduleEntry";
    }

    // The schedule-entry and timings APIs are NOT proxied here. They are served by the
    // Backend (AdmissionTimingController on :5050), and the pages reach it directly through
    // window.API_BASE_URL. The two stubs that used to live here shadowed nothing real —
    // they had no callers — but echoing back success without persisting anything was a trap.

    /** True when the request has no authenticated session; callers redirect to the login page. */
    private static boolean notLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null || session.getAttribute("sessionUser") == null;
    }
}
