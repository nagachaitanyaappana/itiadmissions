package com.server.frontend.controller.checkmeritschedulecontroller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Page routes for the general-pool activation screens, ported from the legacy
 * {@code OpenGeneralPool.jsp}, {@code open_pool_dist_level.jsp} (district) and
 * {@code WEB-INF/open_pool_iti_level.jsp} (ITI).
 *
 * <p>The mutation itself happens in the Backend ({@code POST /api/admission/general-pool/...}),
 * called from the page scripts with the session's role/institution scope headers — the same split
 * used by every other ported page.
 */
@Controller
public class GeneralPoolController {

    /** Legacy {@code OpenGeneralPool.jsp}: the generic landing page. */
    @GetMapping("/OpenGeneralPool")
    public String openGeneralPool(HttpServletRequest request) {
        if (notLoggedIn(request)) {
            return "redirect:/?error=session";
        }
        return "checkmeritschedule/openGeneralPool";
    }

    /** Legacy {@code open_pool_dist_level.jsp}: district login opens its own district's pool. */
    @GetMapping("/OpenPoolDistrict")
    public String openPoolDistrict(HttpServletRequest request) {
        if (notLoggedIn(request)) {
            return "redirect:/?error=session";
        }
        if (!"3".equals(roleOf(request))) {
            return "redirect:/authHome";
        }
        return "checkmeritschedule/openPoolDistrict";
    }

    /** Legacy {@code WEB-INF/open_pool_iti_level.jsp}: ITI login opens its own ITI's pool. */
    @GetMapping("/OpenPoolIti")
    public String openPoolIti(HttpServletRequest request) {
        if (notLoggedIn(request)) {
            return "redirect:/?error=session";
        }
        if (!"4".equals(roleOf(request))) {
            return "redirect:/authHome";
        }
        return "checkmeritschedule/openPoolIti";
    }

    private static String roleOf(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object role = session == null ? null : session.getAttribute("roleId");
        return role == null ? "" : String.valueOf(role);
    }

    private static boolean notLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null || session.getAttribute("sessionUser") == null;
    }
}
