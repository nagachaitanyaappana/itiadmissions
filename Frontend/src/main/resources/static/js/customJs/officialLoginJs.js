/**
 * Official Login JS
 * Handles captcha generation and login authentication for ITI Admissions.
const API_BASE_URL = window.API_BASE_URL;
 * Uses same-origin endpoints (Spring Boot) to avoid CORS issues.
 */

$(document).ready(function() {
    // Initial captcha load
    refreshCaptcha();

    // Trigger login on Enter key
    $("#password, #username, #captcha").keypress(function(event) {
        if (event.which == 13) {
            handleLogin();
        }
    });
});

let captchaToken = null;

/**
 * Fetches a new captcha from the Spring Boot backend (same-origin)
 */
function refreshCaptcha() {
    $("#captchaDisplay").attr("src", "./captcha?ts=" + new Date().getTime());
}

/**
 * Submits credentials to the Spring Boot login API (same-origin)
 */
function handleLogin() {
    const username = $("#username").val().trim();
    const password = $("#password").val().trim();
    const captcha = $("#captcha").val().trim();

    // Basic validation
    if (!username || !password || !captcha) {
        showError("Please fill in all fields.");
        return;
    }

    // Clear previous errors
    $("#errorMsg").hide().text("");

    const form = $("<form>", { method: "POST", action: "./iti/login.do" });
    form.append($("<input>", { type: "hidden", name: "uname", value: username }));
    form.append($("<input>", { type: "hidden", name: "pwd", value: password }));
    form.append($("<input>", { type: "hidden", name: "captcha", value: captcha }));
    $("body").append(form);
    form.submit();
}

/**
 * Displays error messages with a subtle animation
 */
function showError(msg) {
    $("#errorMsg").text(msg).fadeIn();
    // Shake animation effect
    $(".login-card").addClass("shake");
    setTimeout(() => {
        $(".login-card").removeClass("shake");
    }, 500);
}