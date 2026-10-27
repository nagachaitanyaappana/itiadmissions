<nav class="navbar navbar-expand-lg custom-navbar">
    <div class="container-fluid">
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="mainNav">
            <ul class="navbar-nav nav-menu mx-auto">
                <li class="nav-item">
                    <a class="nav-link active" href="${pageContext.request.contextPath}/">Home</a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="itiProfileDropdown" role="button" data-bs-toggle="dropdown">
                        ITI Profile
                    </a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/reports/iti-profile">ITI Profile</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/reports/iti-list">ITI LIST</a></li>
                    </ul>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="striveDropdown" role="button" data-bs-toggle="dropdown">
                        STRIVE
                    </a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/reports/about-strive">ABOUT STRIVE</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/reports/disclosure-management">Disclosure Management</a></li>
                    </ul>
                </li>
                 <li class="nav-item">
                    <a class="nav-link active" href="${pageContext.request.contextPath}/">Login</a>
                </li>
            </ul>
        </div>
    </div>
</nav>
