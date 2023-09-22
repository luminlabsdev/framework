import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "CanaryEngine",
  description: "A lightweight and blazingly fast framework",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      {
        text: 'Guides',
        items: [
          { text: 'Libraries', link: '/tutorials/libraries/benchmark' },
          { text: 'Usage', link: '/tutorials/update' },
        ]
      },
      { text: 'Installation', link: '/getstarted/installation' }
    ],

    sidebar: {
      '/tutorials/libraries/': [
        {
          text: 'Library Guides',
          items: [
            { text: 'Benchmark', link: '/tutorials/libraries/benchmark' },
            { text: 'Debugger', link: '/tutorials/libraries/debugger' },
            { text: 'UIShelf', link: '/tutorials/libraries/uishelf' }
          ]
        }
      ],
    },

    search: {
      provider: 'local'
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/canary-development/CanaryEngine' },
      { icon: 'discord', link: 'https://discord.gg/cwwcZtqJAt'}
    ]
  }
})
