<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>:: ITI Admissions ::</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
:root{--blue:#0d47a1;--blue2:#1976d2;--accent:#42a5f5;}
*{box-sizing:border-box;margin:0;padding:0;}
html,body{height:100%;}
body{font-family:'Inter',sans-serif;background:#f5f7fa;color:#1a237e;min-height:100vh;display:flex;flex-direction:column;overflow-x:hidden;}
.bg-shapes{position:fixed;inset:0;pointer-events:none;z-index:0;overflow:hidden;}
.bg-shapes span{position:absolute;border-radius:50%;filter:blur(60px);opacity:.35;animation:float 12s ease-in-out infinite;}
.bg-shapes span:nth-child(1){width:400px;height:400px;background:#fff;top:-100px;left:-100px;}
.bg-shapes span:nth-child(2){width:500px;height:500px;background:#90caf9;bottom:-150px;right:-150px;animation-delay:3s;}
.bg-shapes span:nth-child(3){width:300px;height:300px;background:#1976d2;top:40%;left:60%;animation-delay:6s;}
@keyframes float{0%,100%{transform:translate(0,0)}50%{transform:translate(30px,-40px)}}
header{position:relative;z-index:1;backdrop-filter:blur(10px);background:rgba(255,255,255,.08);border-bottom:1px solid rgba(255,255,255,.2);padding:18px 0;text-align:center;}
header h1{font-size:24px;font-weight:800;letter-spacing:1.5px;}
header p{font-size:12px;opacity:.85;margin-top:4px;}
nav{position:sticky;top:0;z-index:50;backdrop-filter:blur(12px);background:rgba(13,71,161,.75);border-bottom:1px solid rgba(255,255,255,.15);}
.nav-inner{max-width:1200px;margin:0 auto;padding:0 20px;display:flex;align-items:center;justify-content:space-between;height:64px;}
.brand{display:flex;align-items:center;gap:10px;font-weight:800;font-size:16px;color:#fff;text-decoration:none;}
.brand i{font-size:22px;}
.nav-links{list-style:none;display:flex;gap:4px;flex-wrap:wrap;}
.nav-links li{position:relative;}
.nav-links li a{display:block;padding:8px 14px;color:#fff;text-decoration:none;font-weight:600;font-size:13px;text-transform:uppercase;border-radius:8px;transition:.25s;}
.nav-links li a:hover{background:rgba(255,255,255,.18);}
.dropdown{display:none;position:absolute;top:100%;left:0;background:rgba(13,71,161,.95);backdrop-filter:blur(12px);border-radius:10px;padding:6px;min-width:200px;box-shadow:0 12px 30px rgba(0,0,0,.3);z-index:60;}
.nav-links li:hover .dropdown{display:block;}
.dropdown a{display:block;padding:10px 14px;border-radius:6px;font-size:13px;text-transform:none;}
.dropdown a:hover{background:rgba(255,255,255,.18);}
main{position:relative;z-index:1;flex:1;max-width:1200px;margin:0 auto;padding:60px 20px;width:100%;}
.hero{text-align:center;margin-bottom:60px;}
.hero h2{font-size:44px;font-weight:800;margin-bottom:12px;color:var(--blue);}
.hero p{font-size:18px;color:#555;max-width:600px;margin:0 auto;}
.hero-actions{margin-top:30px;display:flex;gap:16px;justify-content:center;flex-wrap:wrap;}
.btn{padding:14px 30px;border-radius:50px;font-weight:700;text-decoration:none;display:inline-block;transition:.3s;border:none;cursor:pointer;font-size:14px;}
.btn-primary{background:#fff;color:var(--blue);box-shadow:0 8px 24px rgba(0,0,0,.2);}
.btn-primary:hover{transform:translateY(-3px);}
.btn-secondary{background:transparent;color:var(--blue);border:2px solid var(--blue);}
.btn-secondary:hover{background:var(--blue);color:#fff;}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:24px;}
.card{background:#fff;border:1px solid #90caf9;border-radius:18px;padding:32px 24px;text-align:center;transition:.4s;box-shadow:0 4px 16px rgba(13,71,161,.08);}
.card:hover{transform:translateY(-8px);box-shadow:0 12px 28px rgba(13,71,161,.15);}
.card i{font-size:42px;margin-bottom:16px;color:var(--blue);}
.card h3{font-size:18px;font-weight:700;margin-bottom:8px;color:var(--blue);}
.card p{font-size:13px;color:#555;margin-bottom:16px;}
.card a{color:var(--blue);font-weight:700;text-decoration:none;}
.note{background:rgba(255,255,255,.12);backdrop-filter:blur(12px);border-left:4px solid #ffb300;padding:16px 22px;margin-top:40px;border-radius:0 12px 12px 0;font-size:14px;}
.visitor{text-align:right;margin-top:24px;font-size:13px;opacity:.85;}
footer{position:relative;z-index:1;background:rgba(0,0,0,.2);text-align:center;padding:18px 0;font-size:13px;opacity:.9;border-top:1px solid rgba(255,255,255,.15);}
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);backdrop-filter:blur(4px);z-index:100;align-items:center;justify-content:center;}
.modal-overlay.open{display:flex;}
.modal{background:rgba(255,255,255,.95);backdrop-filter:blur(20px);color:#333;border-radius:24px;padding:0;width:90%;max-width:480px;box-shadow:0 40px 80px rgba(0,0,0,.4);position:relative;overflow:hidden;}
.modal-header{background:linear-gradient(135deg,var(--blue),var(--accent));padding:32px 40px;color:#fff;text-align:center;}
.modal-header h3{font-size:26px;font-weight:800;margin:0;}
.modal-header p{font-size:13px;opacity:.9;margin-top:6px;}
.modal-body{padding:32px 40px;}
.modal-body .input-group{position:relative;margin-bottom:16px;}
.modal-body .input-group i{position:absolute;left:16px;top:50%;transform:translateY(-50%);color:var(--blue);}
.modal-body input{width:100%;padding:14px 16px 14px 44px;border:2px solid #e0e0e0;border-radius:12px;font-size:15px;background:#f8fafc;}
.modal-body input:focus{outline:none;border-color:var(--blue);background:#fff;box-shadow:0 0 0 4px rgba(13,71,161,.1);}
.modal-body button{width:100%;padding:14px;border:none;border-radius:12px;background:linear-gradient(135deg,var(--blue),var(--accent));color:#fff;font-weight:700;font-size:15px;cursor:pointer;margin-top:8px;}
.modal .close{position:absolute;top:16px;right:20px;background:rgba(255,255,255,.2);border:none;border-radius:50%;width:32px;height:32px;font-size:18px;color:#fff;cursor:pointer;display:flex;align-items:center;justify-content:center;}
@keyframes fadeUp{from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)}}
</style>
</head>
<body>
<div class="bg-shapes"><span></span><span></span><span></span></div>
<header>
  <h1>ITI Admissions Portal</h1>
  <p>Government of Andhra Pradesh &bull; Developed by NIC</p>
</header>
<nav>
  <div class="nav-inner">
    <a href="${pageContext.request.contextPath}/" class="brand"><i class="fas fa-graduation-cap"></i> ITI Admissions</a>
    <ul class="nav-links">
      <li><a href="${pageContext.request.contextPath}/" class="active">Home</a></li>
      <li><a href="javascript:void(0)">ITI Profile</a>
        <div class="dropdown">
          <a href="${pageContext.request.contextPath}/reports/iti-profile">ITI Profile</a>
          <a href="${pageContext.request.contextPath}/reports/iti-list">ITI List</a>
        </div>
      </li>
      <li><a href="javascript:void(0)">About STRIVE</a>
        <div class="dropdown">
          <a href="${pageContext.request.contextPath}/reports/about-strive">About STRIVE</a>
          <a href="${pageContext.request.contextPath}/reports/disclosure-management">Disclosure Management</a>
        </div>
      </li>
      <li><a href="#" onclick="document.getElementById('loginModal').classList.add('open');return false;">Login</a></li>
    </ul>
  </div>
</nav>
<main>
  <section class="hero">
    <h2>Welcome to ITI Admissions</h2>
    <p>Your gateway to Industrial Training Institute admissions in Andhra Pradesh</p>
    <div class="hero-actions">
      <a href="${pageContext.request.contextPath}/student-registration" class="btn btn-primary">Get Started</a>
      <a href="${pageContext.request.contextPath}/Course" class="btn btn-secondary">Explore Courses</a>
    </div>
  </section>
  <div class="grid">
    <div class="card"><i class="fas fa-user-graduate"></i><h3>Student Registration</h3><p>Register your personal details to get a Registration Number</p><a href="${pageContext.request.contextPath}/student-registration">Register Now <i class="fas fa-arrow-right"></i></a></div>
    <div class="card"><i class="fas fa-file-alt"></i><h3>Apply for ITI</h3><p>Select districts, trades, and units to apply for admission</p><a href="${pageContext.request.contextPath}/student-apply">Apply Now <i class="fas fa-arrow-right"></i></a></div>
    <div class="card"><i class="fas fa-edit"></i><h3>Edit Details</h3><p>Update your registered information before final submission</p><a href="${pageContext.request.contextPath}/student-edit-details">Edit <i class="fas fa-arrow-right"></i></a></div>
    <div class="card"><i class="fas fa-key"></i><h3>Forgot Registration ID</h3><p>Retrieve your registration number if you have forgotten it</p><a href="${pageContext.request.contextPath}/forgot-regid">Retrieve <i class="fas fa-arrow-right"></i></a></div>
  </div>
<% String err = request.getParameter("error"); if (err != null) { %>
<div class="note" style="border-left-color:#d32f2f;background:rgba(211,47,47,.15);">
  <b><%= "captcha".equals(err) ? "Invalid captcha, please try again."
    : "invalid".equals(err) ? "Invalid username or password."
    : "inactive".equals(err) ? "Your account is inactive. Contact administrator."
    : "session".equals(err) ? "Please login to continue."
    : "Login service unavailable, please try again later." %></b>
</div>
<% } %>
  <div class="visitor"><b>No of Visitors:</b> <span id="visitorCount"></span></div>
</main>
<div class="modal-overlay" id="loginModal" onclick="if(event.target===this)this.classList.remove('open')">
  <div class="modal">
    <button class="close" onclick="document.getElementById('loginModal').classList.remove('open')">&times;</button>
    <div class="modal-header"><h3>Welcome Back</h3><p>Sign in to continue to ITI Admissions</p></div>
    <div class="modal-body">
      <div id="loginError" style="display:none;background:rgba(211,47,47,.12);color:#b71c1c;padding:10px 14px;border-radius:10px;margin-bottom:14px;font-size:13px;font-weight:600;"></div>
      <form id="loginForm" action="${pageContext.request.contextPath}/iti/login.do" method="post" onsubmit="return submit1();">
        <div class="input-group"><i class="fas fa-user"></i><input id="loginUname" name="uname" minlength="2" type="text" autocomplete="off" required autofocus placeholder="Registration No / User Name" /></div>
        <div class="input-group"><i class="fas fa-lock"></i><input id="loginPwd" name="pwd" minlength="2" type="password" required autocomplete="off" placeholder="Password" /></div>
        <input type="hidden" name="pwdd" id="loginPwdd" />
        <div class="input-group" style="display:flex;gap:10px;align-items:center;">
          <i class="fas fa-shield-alt" style="position:relative;left:0;transform:none;"></i>
          <input type="text" id="loginCaptcha" name="captcha" maxlength="4" required placeholder="Captcha" style="margin:0;flex:1;padding-left:16px;" onblur="validateFreeSpace(this.value, this, 'Please Enter The Letters Shown In Picture')" />
          <img src="${pageContext.request.contextPath}/captcha" id="loginCaptchaImage" alt="Captcha" style="height:46px;border-radius:10px;border:1px solid #ddd;" />
        </div>
        <span id="loginCaptchaRef" style="cursor:pointer;font-size:12px;color:var(--blue);font-weight:600;display:block;margin-bottom:12px;" onclick="refreshCaptcha()">Refresh Captcha</span>
        <button type="submit" id="loginMysubmit">Sign In</button>
      </form>
    </div>
  </div>
</div>
<footer>&copy; 2026 Government of Andhra Pradesh. All Rights Reserved. Developed by NIC.</footer>
<script src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
<script>
function submit1() { return true; }
function validateFreeSpace(value, obj, message) { if (value === '') { alert(message); obj.focus(); return false; } return true; }
function refreshCaptcha() { var t=(new Date()).getTime(); var s=$("#loginCaptchaImage").attr("src").split("?"); $("#loginCaptchaImage").attr("src", s[0]+"?"+t); }
$(document).ready(function(){
  var params = new URLSearchParams(window.location.search);
  var err = params.get('error');
  if (err) {
    var msg = err==='captcha' ? 'Invalid captcha, please try again.' :
             err==='invalid' ? 'Invalid username or password.' :
             err==='inactive' ? 'Your account is inactive. Contact administrator.' :
             err==='session' ? 'Please login to continue.' : 'Login service unavailable, please try again later.';
    $('#loginError').text(msg).show();
    $('#loginModal').addClass('open');
  }
  $("#loginCaptcha").keypress(function(ev){ if(ev.keyCode===13) $("#loginMysubmit").click(); });
});
</script>
</body>
</html>