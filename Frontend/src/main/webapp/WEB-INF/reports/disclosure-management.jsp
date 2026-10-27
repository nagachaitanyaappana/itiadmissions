<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>:: Disclosure Management ::</title>
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
        /* Make all borders blue */
        .card{border-color:#007bff !important}
        .table{border-color:#007bff !important}
        .table-bordered{border-color:#007bff !important}
        .table-bordered td,.table-bordered th{border-color:#007bff !important}
        .btn{border-color:#007bff !important}
        .btn-primary{border-color:#007bff !important}
        .btn-success{border-color:#007bff !important}
        /* STRIVE content text */
        .text1{font-size:20px;padding-left:65px;}
        .text1 p:before{content:'\25BA ';}
        p:before{content:'\25BA ';}
        /* Hidden sections revealed on Goods click */
        #striveDescription{display:none;}
        #itiMisCodeList{display:none;}
    </style>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</head>
<body>
    <header>
        <%@ include file="../jsp/header.jsp" %>
    </header>

    <div class="container my-4">
        <h4 class="text-primary text-center mb-4">Disclosure Management</h4>

        <div class="card shadow-sm">
            <div class="card-body">
                <!-- Middle table: Disclosures Management (always visible) -->
                <h5 class="card-title text-center fw-bold text-primary">Disclosures Management</h5>
                <div class="table-responsive">
                    <table class="table table-bordered table-striped align-middle disclosure-table" style="min-width:650px;">
                        <thead class="table-blue">
                            <tr style="background:#0057AF;color:white">
                                <th class="text-center">SNO</th>
                                <th class="text-center">Disclosures Management</th>
                                <th class="text-center"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td rowspan="3" align="right" class="text-center">1</td>
                                <td rowspan="3">Approved Procurement Plan and updates</td>
                                <td><a href="javascript:iti_display(1);">Goods</a></td>
                            </tr>
                            <tr><td>Services</td></tr>
                            <tr><td>Works</td></tr>
                            <tr>
                                <td rowspan="3" align="right" class="text-center">2</td>
                                <td rowspan="3">Invitation for Bids</td>
                                <td><a href="javascript:iti_display(2);">Goods</a></td>
                            </tr>
                            <tr><td>Services</td></tr>
                            <tr><td>Works</td></tr>
                            <tr>
                                <td rowspan="3" align="right" class="text-center">3</td>
                                <td rowspan="3">Short list of consultants/Bidders</td>
                                <td><a href="javascript:iti_display(3);">Goods</a></td>
                            </tr>
                            <tr><td>Services</td></tr>
                            <tr><td>Works</td></tr>
                            <tr>
                                <td rowspan="3" align="right" class="text-center">4</td>
                                <td rowspan="3">Contract Awards</td>
                                <td><a href="javascript:iti_display(4);">Goods</a></td>
                            </tr>
                            <tr><td>Services</td></tr>
                            <tr><td>Works</td></tr>
                            <tr>
                                <td rowspan="3" align="right" class="text-center">5</td>
                                <td rowspan="3">Action taken</td>
                                <td><a href="javascript:iti_display(5);">Goods</a></td>
                            </tr>
                            <tr><td>Services</td></tr>
                            <tr><td>Works</td></tr>
                        </tbody>
                    </table>
                </div>

                <br>

                <!-- STRIVE description: hidden until Goods clicked -->
                <div id="striveDescription">
                    <h5 class="card-title text-center fw-bold text-primary">
                        Skills Strengthening of Industrial Value Enhancement (STRIVE) Project in State of Andhra Pradesh
                    </h5>
                    <div class="text1">
                        <p>Objective of the scheme is to improve the relevance and efficiency of skills Training provided through Industrial Training Institutes (ITIs) and Apprenticeships, duly upgrading the infrastructure, equipment and machinery.</p>
                        <p>STRIVE is a Central Sector Scheme with no State Contribution, assisted by World Bank.</p>
                        <p>It is a 5 Year Project, closing by November 2022.</p>
                        <p>STRIVE Scheme has four result areas.</p>
                        <p>Result Area 1 - Improved Performance of ITIs</p>
                        <p>Result Area 2 - Increased Capacities of State Governments to support ITIs and Apprenticeship Training</p>
                        <p>Result Area 3 - Improved Teaching and Learning</p>
                        <p>Result Area 4 - Improved and Broadened Apprenticeship Training.</p>
                        <p>15 Govt. ITIs have been selected under the scheme and Institute Management Committees are also constituted in these ITIs.</p>
                        <p>Govt. of A.P have made an Agreement (Performance Based Fund Agreement) with Govt. of India in Feb 2019 accepting terms and Conditions of the Project.</p>
                    </div>
                </div>

                <br>

                <!-- ITI MIS Code List table: hidden until Goods clicked -->
                <div id="itiMisCodeList">
                    <h5 class="card-title text-center fw-bold text-primary">ITI MIS Code List</h5>
                    <div class="table-responsive">
                        <table class="table table-bordered table-striped align-middle disclosure-table" style="min-width:650px;">
                            <thead class="table-blue">
                                <tr style="background:#0057AF;color:white">
                                    <th class="text-center">SNO</th>
                                    <th class="text-center">ITI MIS CODE</th>
                                    <th class="text-center">Name of the ITI</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr><td class="text-center">1</td><td>GR28000416</td><td><a href="./SPMU/Goods/1Rajam.pdf" target="_blank">GOVT ITI RAJAM</a></td></tr>
                                <tr><td class="text-center">2</td><td>GR28000154</td><td><a href="./SPMU/Goods/1Bobbili.pdf" target="_blank">GOVT ITI BOBBLLI</a></td></tr>
                                <tr><td class="text-center">3</td><td>GU28000144</td><td><a href="./SPMU/Goods/1Vizag(O).pdf" target="_blank">GOVT.ITI VISAKHAPATNAM</a></td></tr>
                                <tr><td class="text-center">4</td><td>GR28000238</td><td><a href="./SPMU/Goods/2KAKINADA.pdf" target="_blank">GOVT.ITI KAKINADA</a></td></tr>
                                <tr><td class="text-center">5</td><td>GR28000123</td><td><a href="./SPMU/Goods/2Bhimavaram.pdf" target="_blank">GOVT.ITI BHIMAVARAM</a></td></tr>
                                <tr><td class="text-center">6</td><td>GR28000151</td><td><a href="./SPMU/Goods/2Vijayawaa.pdf" target="_blank">GOVT.ITI VIJAYAWADA</a></td></tr>
                                <tr><td class="text-center">7</td><td>GR28000206</td><td><a href="./SPMU/Goods/3Tenali.pdf" target="_blank">GOVT.ITI TENALI</a></td></tr>
                                <tr><td class="text-center">8</td><td>GR28000155</td><td><a href="./SPMU/Goods/3Ongole(B).pdf" target="_blank">GOVT.ITI ONGOLE(B)</a></td></tr>
                                <tr><td class="text-center">9</td><td>GR28000270</td><td><a href="./SPMU/Goods/3Nellore(G).pdf" target="_blank">GOVT ITI NELLORE(G)</a></td></tr>
                                <tr><td class="text-center">10</td><td>GR28000145</td><td><a href="./SPMU/Goods/3Nellore(B).pdf" target="_blank">GOVT.ITI NELLORE(B)</a></td></tr>
                                <tr><td class="text-center">11</td><td>GR28000308</td><td><a href="./SPMU/Goods/3Tada.pdf" target="_blank">GOVT.ITI TADA</a></td></tr>
                                <tr><td class="text-center">12</td><td>GR28000041</td><td><a href="./SPMU/Goods/4srisailem.pdf" target="_blank">GOVT.ITI SRISAILEM</a></td></tr>
                                <tr><td class="text-center">13</td><td>GR28000335</td><td><a href="./SPMU/Goods/4CHITTOOR.pdf" target="_blank">GOVT.ITI CHITTOOR</a></td></tr>
                                <tr><td class="text-center">14</td><td>GR28000182</td><td><a href="./SPMU/Goods/4Thirupathi.pdf" target="_blank">GOVT.ITI TIRUPATHI</a></td></tr>
                                <tr><td class="text-center">15</td><td>GR28000386</td><td><a href="./SPMU/Goods/4Chakrayapeta..pdf" target="_blank">GOVT.ITI CHKRYAPETA</a></td></tr>
                                <tr><td class="text-center">16</td><td>State Project Implementation Unit (SPIU)</td><td><a href="SPMU.jsp">Directorate of Employment and Training, Vijayawada</a></td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
    function iti_display(rowNum){
       document.getElementById("dispaly_itis").style.display="block";
       // Reveal STRIVE description and ITI MIS Code List when any Goods is clicked
       document.getElementById("striveDescription").style.display = "block";
       document.getElementById("itiMisCodeList").style.display = "block";
    }

    // Show popup on page load
    window.onload = function () {
        var popup = document.getElementById("airforcePopup");
        if (popup) {
            popup.style.display = "block";
            setTimeout(function () {
                popup.style.display = "none";
            }, 10000);
        }
    };

    function closeAirforcePopup() {
        var popup = document.getElementById("airforcePopup");
        if (popup) {
            popup.style.display = "none";
        }
    }
    </script>

    <%@ include file="../footer.jsp" %>
</body>
</html>
