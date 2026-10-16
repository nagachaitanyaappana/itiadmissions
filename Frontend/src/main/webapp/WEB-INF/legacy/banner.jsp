<%
    String img = "";
    try {
        if (session.getAttribute("img").toString().equalsIgnoreCase(null)) {
            img = "gen.jpg";
        } else {
            img = session.getAttribute("img").toString();
          }
    } catch (Exception ex) {
        img = "gen.jpg";
    }
%>
<center>
    <img src="${pageContext.request.contextPath}/images/<%=img%>" id="banner-id" style="width: 100%" alt="banner" />
</center>
