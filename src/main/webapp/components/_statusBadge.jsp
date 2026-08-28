<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
    Reusable status badge. Usage:
    <jsp:include page="../components/_statusBadge.jsp">
        <jsp:param name="status" value="${e.status}" />
    </jsp:include>
--%>
<c:set var="st" value="${param.status}" />
<c:choose>
    <c:when test="${st eq 'APPROVED'}"><span class="badge-status approved"><i class="fa-solid fa-check"></i> APPROVED</span></c:when>
    <c:when test="${st eq 'REJECTED'}"><span class="badge-status rejected"><i class="fa-solid fa-xmark"></i> REJECTED</span></c:when>
    <c:otherwise><span class="badge-status pending"><i class="fa-solid fa-clock"></i> PENDING</span></c:otherwise>
</c:choose>
