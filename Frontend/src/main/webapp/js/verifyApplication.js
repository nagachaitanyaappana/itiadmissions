let currentRegid = null;
let modalCallback = null;

function initPage() {
    const roleId = SESSION_ROLE_ID;
    const insCode = SESSION_INS_CODE;
    const distName = SESSION_DIST_NAME;

    if (!roleId || roleId !== "3") {
        document.getElementById('verifyForm').style.display = 'none';
        document.getElementById('resultSection').style.display = 'none';
        document.body.innerHTML += '<div style="max-width:600px;margin:40px auto;padding:20px;background:#f8d7da;border:1px solid #f5c6cb;border-radius:4px;color:#721c24;text-align:center;">Access denied: District login required.</div>';
        return;
    }
}

function validate(event) {
    event.preventDefault();
    const regid = document.getElementById('regid').value.trim();
    const msgEl = document.getElementById('msgBox');

    if (!regid) {
        alert("Registration Id is required");
        return false;
    }
    searchApplication();
    return false;
}

function searchApplication() {
    const regid = document.getElementById('regid').value.trim();
    const msgEl = document.getElementById('msgBox');

    if (!regid) {
        msgEl.textContent = 'Please enter a Registration ID';
        msgEl.style.color = '#dc3545';
        return;
    }

    msgEl.textContent = 'Searching...';
    msgEl.style.color = '#0056b3';

    const insCode = SESSION_INS_CODE || '';

    fetch(`${API_BASE_URL}/api/dv/lookup?regid=${encodeURIComponent(regid)}&distCode=${encodeURIComponent(insCode)}`)
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                msgEl.textContent = 'Application found';
                msgEl.style.color = '#28a745';
                currentRegid = regid;
                renderResult(data);
            } else {
                msgEl.textContent = data.message || 'Search failed';
                msgEl.style.color = '#dc3545';
                hideResult();
            }
        })
        .catch(err => {
            console.error(err);
            msgEl.textContent = 'Network error: ' + err.message;
            msgEl.style.color = '#dc3545';
        });
}

function hideResult() {
    document.getElementById('resultSection').style.display = 'none';
    document.getElementById('btnApprove').disabled = true;
    document.getElementById('btnReject').disabled = true;
}

/** Fetches the stored photo (base64 in JSON) and shows it as a data URI in both previews. */
function loadStudentPhoto() {
    const photoEl = document.getElementById('studentPhoto');
    const photoLarge = document.getElementById('studentPhotoLarge');
    const noPhotoEl = document.getElementById('noPhotoPlaceholder');
    const noPhotoLarge = document.getElementById('noPhotoLarge');
    fetch(`${API_BASE_URL}/api/student/photo/${encodeURIComponent(currentRegid)}`)
        .then(r => r.json())
        .then(payload => {
            const b64 = payload && payload.photo ? String(payload.photo) : '';
            if (!b64) {
                showNoPhoto();
                return;
            }
            const src = b64.startsWith('data:image') ? b64 : 'data:image/jpeg;base64,' + b64;
            photoEl.src = src;
            photoEl.style.display = 'block';
            noPhotoEl.style.display = 'none';
            photoLarge.src = src;
            photoLarge.style.display = 'block';
            noPhotoLarge.style.display = 'none';
        })
        .catch(err => {
            console.error('Photo load failed:', err);
            showNoPhoto();
        });
}

/** Hides both photo previews and shows the "No Photo" placeholders. */
function showNoPhoto() {
    document.getElementById('studentPhoto').style.display = 'none';
    document.getElementById('noPhotoPlaceholder').style.display = 'block';
    document.getElementById('studentPhotoLarge').style.display = 'none';
    document.getElementById('noPhotoLarge').style.display = 'block';
}

function renderResult(data) {
    const app = data.student;
    const marks = data.marks;
    const appStatus = data.appStatus || 'N';
    const allowed = data.allowed;
    const alreadyApproved = data.alreadyInApplication;

    // Status badge
    const badge = document.getElementById('statusBadge');
    badge.textContent = statusLabel(appStatus);
    badge.style.backgroundColor = statusBgColor(appStatus);
    badge.style.color = statusTextColor(appStatus);
    badge.style.padding = '4px 10px';
    badge.style.borderRadius = '4px';
    badge.style.fontSize = '12px';
    badge.style.fontWeight = 'bold';

    // Student photo. The backend's GET /api/student/photo/{regid} returns the image *base64 in
    // JSON* ({"regid":..,"photo":"..."}), not raw image bytes. Pointing <img src=...> straight at
    // it made the browser receive JSON and render nothing, so fetch it and embed a data URI.
    if (data.hasPhoto) {
        loadStudentPhoto();
    } else {
        showNoPhoto();
    }

    // Personal details
    setText('d_regid', app.regid);
    setText('d_ssc_regno', app.ssc_regno);
    setText('d_name', app.name);
    setText('d_fname', app.fname);
    setText('d_mname', app.mname);
    setText('d_dob', formatDate(app.dob));
    setText('d_gender', app.gender);
    setText('d_caste', app.caste);
    setText('d_phno', app.phno);
    setText('d_adarno', app.adarno);
    setText('d_addr', app.addr);
    setText('d_local', app.local);
    setText('d_ssc_board', app.ssc_board);
    setText('d_ssc_year', app.ssc_year);
    setText('d_ssc_month', app.ssc_month);

    // Marks
    renderMarks(marks);

    // Document verification - pre-populate from student data
    populateDocumentVerification(app);

    // District scope message
    const scopeEl = document.getElementById('districtScopeMsg');
    if (!allowed) {
        scopeEl.innerHTML = '<div class="alert alert-warning">This application has no ITI selected in your district (' + (SESSION_DIST_NAME || SESSION_INS_CODE) + '). Approval is not allowed.</div>';
        disableActions();
    } else if (alreadyApproved) {
        scopeEl.innerHTML = '<div class="alert alert-info">This application has already been approved.</div>';
        disableActions();
    } else if (appStatus === 'A') {
        scopeEl.innerHTML = '<div class="alert alert-success">This application is already approved.</div>';
        disableActions();
    } else if (appStatus === 'R') {
        scopeEl.innerHTML = '<div class="alert alert-danger">This application is rejected.</div>';
        disableActions();
    } else {
        scopeEl.innerHTML = '<div class="alert alert-success">Application is within your district and ready for verification.</div>';
        enableActions();
    }

    document.getElementById('resultSection').style.display = 'block';
}

function populateDocumentVerification(app) {
    // Map app fields to document radio buttons
    const docMap = {
        'doc_ssc_eq': app.ssc_eq_marks,
        'doc_tc': app.tc,
        'doc_cc': app.caste_certificate,
        'doc_pc': app.ph_challenge,
        'doc_exsv': app.ex_service,
        'doc_sc': app.study_certificate,
        'doc_nc': app.nativity_certificate,
        'doc_uidv': app.uidv,
        'doc_ewsv': app.ewsv,
        'doc_age21': app.age_21,
        'doc_exp': app.experience,
        'doc_est': app.est
    };

    for (const [name, value] of Object.entries(docMap)) {
        const val = value ? String(value).toUpperCase() : 'N/A';
        const radio = document.querySelector(`input[name="${name}"][value="${val === 'YES' ? 'Yes' : val === 'NO' ? 'No' : 'N/A'}"]`);
        if (radio) radio.checked = true;
    }
}

function disableActions() {
    document.getElementById('btnApprove').disabled = true;
    document.getElementById('btnReject').disabled = true;
    document.querySelectorAll('input[name="decision"]').forEach(r => r.disabled = true);
    document.querySelectorAll('.doc-radio').forEach(r => r.disabled = true);
}

function enableActions() {
    document.getElementById('btnApprove').disabled = false;
    document.getElementById('btnReject').disabled = false;
    document.querySelectorAll('input[name="decision"]').forEach(r => r.disabled = false);
    document.querySelectorAll('.doc-radio').forEach(r => r.disabled = false);
}

function statusLabel(status) {
    switch (status) {
        case 'A': return 'Approved (A)';
        case 'R': return 'Rejected (R)';
        case 'N': default: return 'New / Pending (N)';
    }
}

function statusBgColor(status) {
    switch (status) {
        case 'A': return '#28a745';
        case 'R': return '#dc3545';
        case 'N': default: return '#ffc107';
    }
}

function statusTextColor(status) {
    switch (status) {
        case 'A': return '#fff';
        case 'R': return '#fff';
        case 'N': default: return '#212529';
    }
}

function formatDate(d) {
    if (!d) return '';
    try {
        const dt = new Date(d);
        if (isNaN(dt.getTime())) return d;
        return dt.toLocaleDateString('en-GB');
    } catch { return d; }
}

function setText(id, val) {
    const el = document.getElementById(id);
    if (el) el.textContent = val == null ? '' : val;
}

function renderMarks(marks) {
    const tbody = document.getElementById('marksBody');
    if (!marks) {
        tbody.innerHTML = '<tr><td colspan="2" style="text-align:center;color:#666;padding:12px;">No marks data available</td></tr>';
        document.getElementById('totalScore').textContent = '-';
        return;
    }

    const subjects = [
        {label: 'First Language', marks: 'ssc_first_lang_marks', gpa: 'ssc_first_lang_gpa'},
        {label: 'Second Language', marks: 'ssc_second_lang_marks', gpa: 'ssc_second_lang_gpa'},
        {label: 'English', marks: 'ssc_eng_marks', gpa: 'ssc_eng_gpa'},
        {label: 'Mathematics', marks: 'ssc_math_marks', gpa: 'ssc_math_gpa'},
        {label: 'Science', marks: 'ssc_sci_marks', gpa: 'ssc_sci_gpa'},
        {label: 'Social', marks: 'ssc_social_marks', gpa: 'ssc_social_gpa'},
    ];

    let rows = '';
    for (const s of subjects) {
        const m = marks[s.marks];
        const g = marks[s.gpa];
        const score = (m !== null && m !== undefined && m !== '') ? m : 
                       (g !== null && g !== undefined && g !== '') ? g : '-';
        rows += `<tr><td style="padding:6px;border:1px solid #ddd;">${s.label}</td><td style="text-align:center;padding:6px;border:1px solid #ddd;">${score}</td></tr>`;
    }
    document.getElementById('marksBody').innerHTML = rows;

    const total = (marks.ssc_tot_marks !== null && marks.ssc_tot_marks !== undefined && marks.ssc_tot_marks !== '') 
        ? marks.ssc_tot_marks 
        : marks.ssc_tot_gpa;
    document.getElementById('totalScore').textContent = total ?? '-';
}

function showRejectReason() {
    document.getElementById('rejectReasonDiv').style.display = 'block';
    document.getElementById('rejectReason').focus();
}

function hideRejectReason() {
    document.getElementById('rejectReasonDiv').style.display = 'none';
}

function submitDecision(action) {
    // Collect document verification data
    const docData = collectDocumentData();

    if (action === 'Reject') {
        showRejectReason();
        return;
    }

    // Approve
    const btn = document.getElementById('btnApprove');
    btn.disabled = true;
    btn.textContent = 'Approving...';

    const payload = {
        regid: currentRegid,
        distCode: SESSION_INS_CODE,
        username: SESSION_USERNAME,
        decision: 'Approve',
        documents: docData
    };

    fetch(`${API_BASE_URL}/api/dv/approve`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(payload)
    })
    .then(r => r.json())
    .then(data => {
        btn.disabled = false;
        if (data.success) {
            showToast('success', 'Approved: ' + data.message);
            searchApplication();
        } else {
            showToast('danger', 'Approve failed: ' + (data.message || 'Unknown error'));
        }
    })
    .catch(err => {
        console.error(err);
        btn.disabled = false;
        showToast('danger', 'Network error: ' + err.message);
    });
}

function collectDocumentData() {
    const docs = {};
    document.querySelectorAll('.doc-radio:checked').forEach(r => {
        docs[r.name] = r.value;
    });
    return docs;
}

function showRejectReason() {
    document.getElementById('rejectReasonDiv').style.display = 'block';
    document.getElementById('rejectReason').focus();
}

function hideRejectReason() {
    document.getElementById('rejectReasonDiv').style.display = 'none';
}

function confirmReject() {
    const reason = document.getElementById('rejectReason').value.trim();
    if (!reason) {
        alert('Please enter a rejection reason');
        return;
    }

    const btn = document.getElementById('btnReject');
    btn.disabled = true;
    btn.textContent = 'Rejecting...';

    const payload = {
        regid: currentRegid,
        distCode: SESSION_INS_CODE,
        username: SESSION_USERNAME,
        decision: 'Reject',
        reason: reason
    };

    fetch(`${API_BASE_URL}/api/dv/reject`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(payload)
    })
    .then(r => r.json())
    .then(data => {
        btn.disabled = false;
        document.getElementById('rejectReasonDiv').style.display = 'none';
        if (data.success) {
            showToast('success', 'Rejected: ' + data.message);
            searchApplication();
        } else {
            showToast('danger', 'Reject failed: ' + (data.message || 'Unknown error'));
        }
    })
    .catch(err => {
        console.error(err);
        btn.disabled = false;
        showToast('danger', 'Network error: ' + err.message);
    });
}

function showToast(type, message) {
    const container = document.getElementById('verifyMsg');
    const bg = type === 'success' ? '#d4edda' : '#f8d7da';
    const border = type === 'success' ? '#c3e6cb' : '#f5c6cb';
    const color = type === 'success' ? '#155724' : '#721c24';
    const icon = type === 'success' ? '✓' : '✕';
    container.innerHTML = `<div class="alert alert-${type}">${icon} ${message}</div>`;
}