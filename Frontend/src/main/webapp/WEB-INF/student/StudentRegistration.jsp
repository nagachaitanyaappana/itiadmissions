<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>:: ITI :: Student Registration ::</title>
    <link rel="shortcut icon" type="image/ico" href="${pageContext.request.contextPath}/images/iti.png" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/all.min.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
    <style>
        .form-select,.form-control{border-color:#007bff !important}
        .form-select:focus,.form-control:focus{border-color:#007bff !important;box-shadow:0 0 0 0.2rem rgba(0,123,255,.25)}
        .table-blue{background:#fff}
        .table-blue th{background:#007bff;color:#fff}
        .table-blue td,.table-blue th{border-color:#007bff}
        .card{border-color:#007bff !important}
        .table{border-color:#007bff !important}
        .table-bordered{border-color:#007bff !important}
        .table-bordered td,.table-bordered th{border-color:#007bff !important}
        .btn{border-color:#007bff !important}
        .btn-primary{border-color:#007bff !important}
        .btn-success{border-color:#007bff !important}
    </style>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</head>
<body>
    <header>
        <%@ include file="../jsp/header.jsp" %>
    </header>

    <div class="container my-4">
        <h4 class="text-primary text-center mb-4">Student Registration</h4>

        <form id="studentRegForm">
            <div class="card shadow-sm">
                <div class="card-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Student Name</label>
                            <input type="text" class="form-control" id="s_name" placeholder="Full Name" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Father's Name</label>
                            <input type="text" class="form-control" id="f_name" placeholder="Father's Name" required>
                        </div>
                    </div>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Date of Birth</label>
                            <input type="date" class="form-control" id="dob" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Gender</label>
                            <select class="form-select" id="gender" required>
                                <option value="">-- Select --</option>
                                <option value="M">Male</option>
                                <option value="F">Female</option>
                            </select>
                        </div>
                    </div>
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Category</label>
                            <select class="form-select" id="category" required>
                                <option value="">-- Select --</option>
                                <option value="OC">OC</option>
                                <option value="BC">BC</option>
                                <option value="SC">SC</option>
                                <option value="ST">ST</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Qualification</label>
                            <select class="form-select" id="qualification" required>
                                <option value="">-- Select --</option>
                                <option value="SSC">SSC</option>
                                <option value="HSC">HSC</option>
                                <option value="Diploma">Diploma</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Course</label>
                            <select class="form-select" id="course" required>
                                <option value="">-- Select --</option>
                                <option value="Engineering">Engineering</option>
                                <option value="Non-Engineering">Non-Engineering</option>
                            </select>
                        </div>
                    </div>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold"> SSC - Total Marks </label>
                            <input type="number" class="form-control" id="ssc_total" placeholder="Out of 600" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold"> SSC - GPA (if applicable) </label>
                            <input type="number" class="form-control" id="ssc_gpa" placeholder="e.g. 9.2" step="0.1">
                        </div>
                    </div>
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label fw-bold"> SSC - First Language </label>
                            <select class="form-select" id="slang">
                                <option value="">-- Select --</option>
                                <option value="Telugu">Telugu</option>
                                <option value="Hindi">Hindi</option>
                                <option value="Urdu">Urdu</option>
                                <option value="English">English</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold"> SSC - Second Language </label>
                            <select class="form-select" id="slang2">
                                <option value="">-- Select --</option>
                                <option value="Telugu">Telugu</option>
                                <option value="Hindi">Hindi</option>
                                <option value="English">English</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold"> SSC - GPA Type </label>
                            <select class="form-select" id="gpatype">
                                <option value=" Marks">Marks</option>
                                <option value=" GPA">GPA</option>
                            </select>
                        </div>
                    </div>
                    <div class="row g-3">
                        <div class="col-md-12">
                            <label class="form-label fw-bold">Address</label>
                            <textarea class="form-control" id="address" rows="3" placeholder="Permanent Address"></textarea>
                        </div>
                    </div>
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Mobile</label>
                            <input type="tel" class="form-control" id="mobile" placeholder="10 digit mobile number" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Email</label>
                            <input type="email" class="form-control" id="email" placeholder="example@email.com" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Aadhaar</label>
                            <input type="text" class="form-control" id="aadhaar" placeholder="12 digit Aadhaar number">
                        </div>
                    </div>
                    <div class="text-center mt-4">
                        <button type="submit" class="btn btn-primary w-100" onclick="submitRegistration()">Register</button>
                    </div>
                </div>
            </div>
        </form>
    </div>

    <script>
function submitRegistration() {
    // Basic validation
    var name = document.getElementById('s_name').value.trim();
    var fname = document.getElementById('f_name').value.trim();
    var dob = document.getElementById('dob').value;
    var gender = document.getElementById('gender').value;
    var category = document.getElementById('category').value;
    var qualification = document.getElementById('qualification').value;
    var course = document.getElementById('course').value;
    var ssc_total = document.getElementById('ssc_total').value.trim();
    var ssc_gpa = document.getElementById('ssc_gpa').value.trim();
    var mobile = document.getElementById('mobile').value.trim();
    var email = document.getElementById('email').value.trim();
    
    if (!name || !fname || !dob || !gender || !category || !qualification || !course) {
        alert('Please fill in all required fields.');
        return false;
    }
    
    if (ssc_total && (ssc_total < 0 || ssc_total > 600)) {
        alert('SSC total marks should be between 0 and 600.');
        return false;
    }
    
    if (mobile && (mobile.length !== 10 || isNaN(mobile))) {
        alert('Please enter a valid 10-digit mobile number.');
        return false;
    }
    
    if (email && !email.includes('@')) {
        alert('Please enter a valid email address.');
        return false;
    }
    
    // Show confirmation
    if (confirm('Are you sure you want to submit this registration?')) {
        // In a real application, this would submit to the backend API
        alert('Registration submitted successfully! Thank you.');
        return true;
    }
    return false;
}
</script>

    <%@ include file="../footer.jsp" %>
</body>
</html>
