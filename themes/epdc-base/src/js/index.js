/**
 * Main theme JavaScript
 * Modern vanilla JavaScript with ES modules
 */

/**
 * Theme initialization
 */
class EPDCTheme {
  constructor() {
    this.init();
  }

  /**
   * Initialize theme functionality
   */
  init() {
    this.setupEventListeners();
    this.handleDOMReady();
    console.log('EPDC Base theme initialized');
  }

  /**
   * Setup global event listeners
   */
  setupEventListeners() {
    // Responsive navigation handler
    this.handleNavigation();
    
    // Smooth scroll for anchor links
    this.handleSmoothScroll();
    
    // Handle reduced motion preference
    this.handleMotionPreference();
  }

  /**
   * DOM ready handler
   */
  handleDOMReady() {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => {
        this.onDOMReady();
      });
    } else {
      this.onDOMReady();
    }
  }

  /**
   * DOM ready callback
   */
  onDOMReady() {
    // Add any DOM-dependent initialization here
    document.body.classList.add('theme-loaded');
  }

  /**
   * Handle mobile navigation
   */
  handleNavigation() {
    const navToggle = document.querySelector('[data-nav-toggle]');
    const navMenu = document.querySelector('[data-nav-menu]');

    if (navToggle && navMenu) {
      navToggle.addEventListener('click', () => {
        const isExpanded = navToggle.getAttribute('aria-expanded') === 'true';
        navToggle.setAttribute('aria-expanded', !isExpanded);
        navMenu.classList.toggle('is-open');
      });
    }
  }

  /**
   * Smooth scroll for anchor links
   */
  handleSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function (e) {
        const target = document.querySelector(this.getAttribute('href'));
        
        if (target) {
          e.preventDefault();
          target.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          });
        }
      });
    });
  }

  /**
   * Handle motion preference
   */
  handleMotionPreference() {
    const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
    
    if (mediaQuery.matches) {
      document.body.classList.add('reduced-motion');
    }

    mediaQuery.addEventListener('change', () => {
      document.body.classList.toggle('reduced-motion', mediaQuery.matches);
    });
  }
}

// Utility functions
const utils = {
  /**
   * Throttle function execution
   */
  throttle(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  },

  /**
   * Debounce function execution
   */
  debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }
};

// Initialize theme
const epdc = new EPDCTheme();

// Export for potential use by other scripts
window.EPDCTheme = epdc;
window.EPDCUtils = utils;