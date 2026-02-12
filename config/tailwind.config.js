export default {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        'elphame-dark': '#0a0a0f',
        'elphame-darker': '#050508',
      }
    }
  },
  plugins: []
}
