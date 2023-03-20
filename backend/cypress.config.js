const { defineConfig } = require('cypress');

module.exports = defineConfig({
  e2e: {
    // We've imported your old cypress plugins here.
    // You may want to clean this up later by importing these.
    setupNodeEvents(on, config) {
      return require('./cypress/plugins/index.js')(on, config);
    },
    baseUrl: 'http://localhost:8000/',
    excludeSpecPattern: ['*/*/**/sf-sac-general-info.cy.js', '*/*/**/display-submissions.cy.js'],
    video: false,
    screenshotOnRunFailure: false
  },
});
