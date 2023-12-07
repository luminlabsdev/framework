import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  head: [['link', { rel: 'icon', href: '/favicon.ico' }]],
  base: "/CanaryEngine/",
  title: "CanaryEngine",
  titleTemplate: "Canary Docs",
  description: "A blazingly fast & lightweight Luau framework",
  lastUpdated: true,
  lang: 'en-us',
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      {
        text: 'Articles',
        items: [
          { text: 'Guides', link: '/guides/' },
          { text: 'Recaps', link: '/recaps/' },
          { text: 'Installation', link: '/installation' },
        ]
      },

      { text: 'API', link: '/api/' },
      { text: 'Changelog', link: '/changelog' },
    ],

    sidebar: {
      '/guides': [
        {
          text: 'Guides',
          items: [
            { text: 'Setup', link: '/guides/' },
            { text: 'Signals', link: '/guides/signals' },
            { text: 'Networking', link: '/guides/networking' },
            { text: 'Debugging', link: '/guides/debugging' }
          ]
        }
      ],
      '/recaps': [
        {
          text: 'Engine Recaps',
          items: [
            { text: 'November 2023', link: '/recaps/' },
            { text: 'October 2023', link: '/recaps/october2023' },
            { text: 'September 2023', link: '/recaps/september2023' },
            { text: 'August 2023', link: '/recaps/august2023' },
            { text: 'July 2023', link: '/recaps/july2023' },
            { text: 'June 2023', link: '/recaps/june2023' }
          ]
        }
      ],

      '/api': [
        {
          text: 'API Reference',
          items: [
            { text: 'Framework', link: '/api/' },

            {
              text: 'Interfaces',
              collapsed: false,
              items: [
                { text: 'FrameworkServer', link: '/api/server' },
                { text: 'FrameworkClient', link: '/api/client' },
                { text: 'FrameworkShared', link: '/api/shared' }
              ]
            },

            {
              text: 'Network',
              collapsed: true,
              items: [
                { text: 'Server', link: '/api/network/server' },
                { text: 'Client', link: '/api/network/client' }
              ]
            },

            {
              text: 'Runtime',
              collapsed: true,
              items: [
                { text: 'Runtime', link: '/api/runtime' },
                { text: 'RuntimeContext', link: '/api/runtime/context' },
                { text: 'RuntimeSettings', link: '/api/runtime/settings' },
                { text: 'RuntimeObjects', link: '/api/runtime/objects' }
              ]
            },

            { text: 'Debugger', link: '/api/debugger' },
            { text: 'Signal', link: '/api/signal' }
          ]
        },
      ],
    },

    outline: [2, 3],

    search: {
      provider: 'local'
    },

    editLink: {
      pattern: 'https://github.com/canary-development/CanaryEngine/edit/main/docs/:path'
    },

    footer: {
      message: 'Built with VitePress',
      copyright: 'Copyright © 2021 - 2023 Canary Softworks'
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/canary-development/CanaryEngine' },
      { icon: 'discord', link: 'https://discord.gg/cwwcZtqJAt' },
    ]
  }
})
