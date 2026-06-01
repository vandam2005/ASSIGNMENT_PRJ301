<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="t" tagdir="/WEB-INF/tags" %>

<t:layout title="Menu">
    <div class="container py-5 text-center text-white">

        <h1 class="text-orange mb-5">Our Menu</h1>

        <!-- MENU 299 -->
        <div class="mb-5">
            <img src="${pageContext.request.contextPath}/static/img/buffe299.png"
                 class="img-fluid rounded shadow"
                 style="max-width: 900px; width: 100%;">
        </div>

        <!-- MENU 399 -->
        <div>
            <img src="${pageContext.request.contextPath}/static/img/buffe399.png"
                 class="img-fluid rounded shadow"
                 style="max-width: 900px; width: 100%;">
        </div>

    </div>
</t:layout>