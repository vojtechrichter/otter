// Trivial script - just here so you have a .js asset to cache
console.log("origin-server: hello from /js/app.js");
document.addEventListener("DOMContentLoaded", function () {
    var p = document.createElement("p");
    p.textContent = "JS loaded at " + new Date().toISOString();
    p.style.color = "#888";
    document.body.appendChild(p);
});
