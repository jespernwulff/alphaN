// R | Stata tabs: choosing a language on one tab switches every tab on the
// page, and the choice is remembered for the next page. A link ending in
// ?lang=stata (or ?lang=r) opens the page in that language.
document.addEventListener('DOMContentLoaded', function () {
  var key = 'alphaN-lang';
  var buttons = document.querySelectorAll('.lang-tabs [data-bs-toggle="tab"]');
  if (!buttons.length || typeof bootstrap === 'undefined') return;

  function showAll(lang, except) {
    buttons.forEach(function (btn) {
      if (btn !== except && btn.getAttribute('data-lang') === lang &&
          !btn.classList.contains('active')) {
        bootstrap.Tab.getOrCreateInstance(btn).show();
      }
    });
  }

  function remember(lang) {
    try { localStorage.setItem(key, lang); } catch (e) {}
  }

  buttons.forEach(function (btn) {
    btn.addEventListener('click', function () {
      // Keep the clicked tab where it is on screen while panes above it
      // change height.
      var before = btn.getBoundingClientRect().top;
      var lang = btn.getAttribute('data-lang');
      remember(lang);
      showAll(lang, btn);
      window.requestAnimationFrame(function () {
        window.scrollBy(0, btn.getBoundingClientRect().top - before);
      });
    });
  });

  var wanted = null;
  try { wanted = new URLSearchParams(window.location.search).get('lang'); } catch (e) {}
  if (wanted !== 'r' && wanted !== 'stata') {
    try { wanted = localStorage.getItem(key); } catch (e) {}
  }
  if (wanted === 'r' || wanted === 'stata') showAll(wanted, null);
});
