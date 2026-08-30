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
    <c:when test="${st eq 'APPROVED'}">
        <span class="badge-status approved" title="Approved for payout"><i class="fa-solid fa-check" style="font-size: 10px;"></i> Approved</span>
    </c:when>
    <c:when test="${st eq 'REJECTED'}">
        <span class="badge-status rejected" title="Claim rejected"><i class="fa-solid fa-xmark" style="font-size: 10px;"></i> Rejected</span>
    </c:when>
    <c:otherwise>
        <span class="badge-status pending" title="Awaiting manager decision"><span class="status-dot-pulse">●</span> Pending review</span>
    </c:otherwise>
</c:choose>

