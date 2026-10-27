<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Student Registration | ITI Admission Portal</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/siteScript.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/customJs/stdAreaJs/studentRegJs.js?v=2"></script>
    <style>
        .registration-exists-container {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 40vh;
            text-align: center;
            margin-top: 50px;
            background-color: #ffffff;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        }
        .message-text {
            color: #0000ff;
            font-size: 1.25rem;
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 5px;
            flex-wrap: wrap;
            justify-content: center;
        }
        .reg-id-box {
            border: 3px solid #ff0000;
            padding: 2px 10px;
            display: inline-block;
            margin: 5px;
        }
        .btn-home-custom {
            background-color: #99ff33;
            border: 1px solid #000;
            color: #000;
            padding: 5px 25px;
            text-decoration: none;
            font-weight: bold;
            display: inline-block;
            margin-top: 30px;
            align-self: center;
        }
        .btn-home-custom:hover {
            background-color: #88ee22;
            color: #000;
        }
    </style>
</head>
<body onload="generateCaptcha();">
    <header>
        <%@include file="../jsp/header.jsp" %>
    </header>
    <main>
        <div align="center" style="color: red;" id="tokenErrMsg"></div>
        <div class="container border p-2 mt-2 font-weight-bolder shadow-lg rounded-3" style="background-color: transparent; border:none !important;" id="formbody">
            <div id="existRegMsg"></div>
            <div id="stdRegDiv" style="display:block !important; padding: 10px;">
                <form id="registrationForm" action="">
                    <!-- Step 1: Personal Details -->
                    <div class="step-active" id="step1">
                        <h4 class="text-center mb-3">Step 1: Personal Details</h4>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label for="s_name" class="form-label">Student Name</label>
                                <input type="text" class="form-control" id="s_name" placeholder="Full Name" required>
                            </div>
                            <div class="col-md-6">
                                <label for="f_name" class="form-label">Father's Name</label>
                                <input type="text" class="form-control" id="f_name" placeholder="Father's Name" required>
                            </div>
                        </div>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label for="dob" class="form-label">Date of Birth</label>
                                <input type="date" class="form-control" id="dob" required>
                            </div>
                            <div class="col-md-6">
                                <label for="gender" class="form-label">Gender</label>
                                <select class="form-select" id="gender" required>
                                    <option value="">-- Select --</option>
                                    <option value="M">Male</option>
                                    <option value="F">Female</option>
                                </select>
                            </div>
                        </div>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label for="category" class="form-label">Category</label>
                                <select class="form-select" id="category" required>
                                    <option value="">-- Select --</option>
                                    <option value="OC">OC</option>
                                    <option value="BC">BC</option>
                                    <option value="SC">SC</option>
                                    <option value="ST">ST</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label for="qualification" class="form-label">Qualification</label>
                                <select class="form-select" id="qualification" required>
                                    <option value="">-- Select --</option>
                                    <option value="SSC">SSC</option>
                                    <option value="HSC">HSC</option>
                                    <option value="Diploma">Diploma</option>
                                </select>
                            </div>
                        </div>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label for="ssc_total" class="form-label">SSC Total Marks</label>
                                <input type="number" class="form-control" id="ssc_total" placeholder="Out of 600" required>
                            </div>
                            <div class="col-md-6">
                                <label for="ssc_gpa" class="form-label">SSC GPA (if applicable)</label>
                                <input type="number" class="form-control" id="ssc_gpa" placeholder="e.g. 9.2" step="0.1">
                            </div>
                        </div>
                        <div class="row g-3">
                            <div class="col-md-4">
                                <label for="slang" class="form-label">First Language</label>
                                <select class="form-select" id="slang">
                                    <option value="">-- Select --</option>
                                    <option value="Telugu">Telugu</option>
                                    <option value="Hindi">Hindi</option>
                                    <option value="Urdu">Urdu</option>
                                    <option value="English">English</option>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label for="slang2" class="form-label">Second Language</label>
                                <select class="form-select" id="slang2">
                                    <option value="">-- Select --</option>
                                    <option value="Telugu">Telugu</option>
                                    <option value="Hindi">Hindi</option>
                                    <option value="English">English</option>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label for="gpatype" class="form-label">GPA Type</label>
                                <select class="form-select" id="gpatype">
                                    <option value=" Marks">Marks</option>
                                    <option value=" GPA">GPA</option>
                                </select>
                            </div>
                        </div>
                        <div class="row g-3">
                            <div class="col-md-12">
                                <label for="address" class="form-label">Address</label>
                                <textarea class="form-control" id="address" rows="3" placeholder="Permanent Address"></textarea>
                            </div>
                        </div>
                        <div class="row g-3">
                            <div class="col-md-4">
                                <label for="mobile" class="form-label">Mobile</label>
                                <input type="tel" class="form-control" id="mobile" placeholder="10 digit mobile number" required>
                            </div>
                            <div class="col-md-4">
                                <label for="email" class="form-label">Email</label>
                                <input type="email" class="form-control" id="email" placeholder="example@email.com" required>
                            </div>
                            <div class="col-md-4">
                                <label for="aadhaar" class="form-label">Aadhaar</label>
                                <input type="text" class="form-control" id="aadhaar" placeholder="12 digit Aadhaar number">
                            </div>
                        </div>
                        <div class="text-center mt-3">
                            <button type="button" class="btn btn-primary w-100" onclick="proceedToStep2()">Proceed to Step 2</button>
                        </div>
                    </div>

                    <!-- Step 2: Full Registration Form (initially hidden) -->
                    <div class="step-inactive" id="step2" style="display:none;">
                        <h4 class="text-center mb-3">Step 2: Full Registration</h4>
                        <!-- Full form from original file would go here -->
                        <p class="text-center">Step 2 form content</p>
                        <button type="button" class="btn btn-secondary w-100" onclick="goBackToStep1()">Back to Step 1</button>
                    </div>

                    <!-- Step 3: Success (initially hidden) -->
                    <div class="step-inactive" id="step3" style="display:none;">
                        <h4 class="text-center mb-3">Step 3: Registration Successful</h4>
                        <div class="registration-exists-container">
                            <div class="message-text">
                                <i class="fas fa-check-circle" style="color: #0000ff;"></i>
                                <span>Registration Submitted Successfully</span>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/" class="btn btn-home-custom">Home</a>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <script>
    // Step navigation
    function proceedToStep2() {
        // Collect step 1 data
        var s_name = document.getElementById('s_name').value.trim();
        var f_name = document.getElementById('f_name').value.trim();
        var dob = document.getElementById('dob').value;
        var gender = document.getElementById('gender').value;
        var category = document.getElementById('category').value;
        var qualification = document.getElementById('qualification').value;
        var ssc_total = document.getElementById('ssc_total').value.trim();
        var ssc_gpa = document.getElementById('ssc_gpa').value.trim();
        var slang = document.getElementById('slang').value;
        var slang2 = document.getElementById('slang2').value;
        var gpatype = document.getElementById('gpatype').value;
        var address = document.getElementById('address').value.trim();
        var mobile = document.getElementById('mobile').value.trim();
        var email = document.getElementById('email').value.trim();
        var aadhaar = document.getElementById('aadhaar').value.trim();

        // Basic validation
        if (!s_name || !f_name || !dob || !gender || !category || !qualification) {
            alert('Please fill in all required fields in Step 1.');
            return;
        }
        if (!ssc_total || ssc_total < 0 || ssc_total > 600) {
            alert('SSC total marks should be between 0 and 600.');
            return;
        }
        if (mobile && (mobile.length !== 10 || isNaN(mobile))) {
            alert('Please enter a valid 10-digit mobile number.');
            return;
        }
        if (email && !email.includes('@')) {
            alert('Please enter a valid email address.');
            return;
        }

        // Hide step 1, show step 2
        document.getElementById('step1').style.display = 'none';
        document.getElementById('step2').style.display = 'block';
        document.getElementById('step3').style.display = 'none';
    }

    function goBackToStep1() {
        document.getElementById('step1').style.display = 'block';
        document.getElementById('step2').style.display = 'none';
        document.getElementById('step3').style.display = 'none';
    }

    function completeRegistration() {
        document.getElementById('step1').style.display = 'none';
        document.getElementById('step2').style.display = 'none';
        document.getElementById('step3').style.display = 'block';
    }
    </script>
</body>
</html>
