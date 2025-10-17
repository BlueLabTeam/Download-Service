
document.addEventListener('DOMContentLoaded', () => {
    // Copyright year update
    document.getElementById('year').textContent = new Date().getFullYear();

    // screenshot thumbs with fade animation
    const thumbs = document.querySelectorAll('.thumb');
    const main = document.getElementById('screenshot-main');

    let currentIndex = 0;
    const fadeDuration = 250;
    const autoInterval = 5000;
    let intervalId;

    function showScreenshot(index) {
        thumbs.forEach(t => t.classList.remove('active'));
        const thumb = thumbs[index];
        thumb.classList.add('active');

        const img = thumb.dataset.img;
        if (!main) return;

        // Fade out
        main.style.transition = `opacity ${fadeDuration}ms ease-in-out`;
        main.style.opacity = '0';

        setTimeout(() => {
            main.style.backgroundImage = `url('${img}')`;
            main.style.opacity = '1';
        }, fadeDuration);
    }

    function startCarousel() {
        clearInterval(intervalId);
        intervalId = setInterval(() => {
            currentIndex = (currentIndex + 1) % thumbs.length;
            showScreenshot(currentIndex);
        }, autoInterval);
    }

    thumbs.forEach((t, i) => {
        t.addEventListener('click', () => {
            currentIndex = i;
            showScreenshot(i);
            startCarousel();
        });
    });

    if (main) main.style.opacity = '1';
    showScreenshot(currentIndex);
    startCarousel();
});

// Smooth scroll
document.addEventListener("DOMContentLoaded", () => {
    const enlaces = document.querySelectorAll('a[href^="#"]');

    enlaces.forEach(enlace => {
        enlace.addEventListener("click", function (e) {
            const destino = document.querySelector(this.getAttribute("href"));
            if (destino) {
                e.preventDefault();
                window.scrollTo({
                    top: destino.offsetTop - 60,
                    behavior: "smooth"
                });
            }
        });
    });
});