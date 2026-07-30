// Site-wide UI scripts: mobile nav toggle, modal popout, and small helpers
document.addEventListener('DOMContentLoaded', function () {
  // Mobile nav toggle
  const navToggle = document.getElementById('navToggle');
  const siteNav = document.getElementById('siteNav');

  if (navToggle && siteNav) {
    navToggle.addEventListener('click', () => {
      const expanded = navToggle.getAttribute('aria-expanded') === 'true';
      navToggle.setAttribute('aria-expanded', String(!expanded));
      siteNav.classList.toggle('open');
    });

    // Close mobile nav on link click
    siteNav.querySelectorAll('a').forEach(a => a.addEventListener('click', () => {
      siteNav.classList.remove('open');
      navToggle.setAttribute('aria-expanded', 'false');
    }));
  }

  // Populate current year if a #year element is present
  const yearEl = document.getElementById('year');
  if (yearEl) yearEl.textContent = new Date().getFullYear();

  // Image modal / popout behavior with focus trap and download
  const trigger = document.getElementById('diagramTrigger');
  const modal = document.getElementById('imageModal');
  const modalImage = document.getElementById('modalImage');
  const origImage = document.getElementById('networkDiagram');
  const closeBtn = modal && modal.querySelector('.modal-close');
  const backdrop = modal && modal.querySelector('.modal-backdrop');
  const downloadLink = modal && modal.querySelector('#modalDownload');
  const mainEl = document.getElementById('main');

  let previouslyFocused = null;

  function getFocusable(el){
    if(!el) return [];
    return Array.prototype.slice.call(el.querySelectorAll('a[href], button:not([disabled]), textarea, input, select, [tabindex]:not([tabindex="-1"])'))
      .filter(function(node){
        // ignore elements that are not visible
        try{
          return (node.offsetWidth > 0 || node.offsetHeight > 0) || node === document.activeElement;
        } catch (e) {
          return false;
        }
      });
  }

  function openModal(){
    if(!modal || !origImage) return;
    previouslyFocused = document.activeElement;
    modalImage.src = origImage.src;
    modalImage.alt = origImage.alt || 'Network architecture diagram';
    // set download href to original image
    if(downloadLink) { downloadLink.href = origImage.src; }
    modal.setAttribute('aria-hidden', 'false');
    // hide main content from assistive tech while modal open
    if(mainEl) mainEl.setAttribute('aria-hidden', 'true');
    // prevent background scroll
    document.body.style.overflow = 'hidden';
    // focus first focusable element inside modal
    const focusables = getFocusable(modal);
    if(focusables.length) focusables[0].focus();
    // listen for Escape and Tab
    document.addEventListener('keydown', keyHandler);
  }

  function closeModal(){
    if(!modal) return;
    modal.setAttribute('aria-hidden', 'true');
    if(mainEl) mainEl.removeAttribute('aria-hidden');
    document.body.style.overflow = '';
    modalImage.src = '';
    // restore focus
    if(previouslyFocused && previouslyFocused.focus) previouslyFocused.focus();
    document.removeEventListener('keydown', keyHandler);
  }

  function keyHandler(e){
    if(e.key === 'Escape') { e.preventDefault(); closeModal(); return; }
    if(e.key === 'Tab'){
      // focus trap: keep focus within modal
      const focusables = getFocusable(modal);
      if(focusables.length === 0) { e.preventDefault(); return; }
      const idx = focusables.indexOf(document.activeElement);
      if(e.shiftKey){
        if(idx === 0 || document.activeElement === modal){
          focusables[focusables.length -1].focus();
          e.preventDefault();
        }
      } else {
        if(idx === focusables.length -1){
          focusables[0].focus();
          e.preventDefault();
        }
      }
    }
  }

  if(trigger){
    trigger.addEventListener('click', function(e){ e.preventDefault(); openModal(); });
  }
  if(closeBtn) closeBtn.addEventListener('click', closeModal);
  if(backdrop) backdrop.addEventListener('click', closeModal);
  // clicking the modal image also closes (convenience)
  if(modalImage) modalImage.addEventListener('click', closeModal);

});
