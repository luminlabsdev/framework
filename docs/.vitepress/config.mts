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
        text: 'Guides',
        items: [
          { text: 'Get Started', link: '/start/intro'},
          { text: 'Usage', link: '/tutorial/styleguide' },
        ]
      },

      {
        text: 'Articles',
        items: [
          { text: 'Blogs', link: '/blog/enginerecaps/enginerecap-october2023' },
          { text: 'Featured', link: '/featured' }
        ]
      },

      { text: 'API', link: '/api/engine/framework/canaryengine'},
      { text: 'Changelog', link: '/changelog'}
    ],

    sidebar: {
      '/start': [
        {
          text: 'Get Started',
          items: [
            { text: 'Introduction', link: '/start/intro' },
            { text: 'Features', link: '/start/features' },
            { text: 'Comparison', link: '/start/comparison' },
            { text: 'Installation', link: '/start/installation' },
            { text: 'FAQ', link: '/start/faq' }
          ]
        }
      ],
      '/tutorial': [
        {
          text: 'Concepts',
          items: [
            { text: 'Style Guide', link: '/tutorial/styleguide' },
            { text: 'Signals', link: '/tutorial/signals' },
            { text: 'Networking', link: '/tutorial/networking' },
          ]
        }
      ],
      '/blog': [
        {
          text: 'Engine Recaps',
          items: [
            { text: 'November 2023', link: '/blog/enginerecaps/enginerecap-november2023' },
            { text: 'October 2023', link: '/blog/enginerecaps/enginerecap-october2023' },
            { text: 'September 2023', link: '/blog/enginerecaps/enginerecap-september2023' },
            { text: 'August 2023', link: '/blog/enginerecaps/enginerecap-august2023' },
            { text: 'July 2023', link: '/blog/enginerecaps/enginerecap-july2023' },
            { text: 'June 2023', link: '/blog/enginerecaps/enginerecap-june2023'}
          ]
        },

        {
          text: 'Announcements',
          items: [

          ]
        }
      ],

      '/api': [
        {
          text: 'API Reference',
          items: [
            {
              text: 'Framework',
              collapsed: true,
              items: [
                { text: 'CanaryEngine', link: '/api/engine/framework/canaryengine' },
                { text: 'CanaryEngineServer', link: '/api/engine/framework/canaryengineserver' },
                { text: 'CanaryEngineClient', link: '/api/engine/framework/canaryengineclient' },
                { text: 'Debugger', link: '/api/engine/framework/debugger' },
              ]
            },

            {
              text: 'Runtime',
              collapsed: true,
              items: [
                { text: 'Runtime', link: '/api/engine/runtime/runtime' },
                { text: 'RuntimeContext', link: '/api/engine/runtime/runtimecontext' },
                { text: 'RuntimeSettings', link: '/api/engine/runtime/runtimesettings' },
                { text: 'RuntimeObjects', link: '/api/engine/runtime/runtimeobjects' }
              ]
            },

            {
              text: 'Signals',
              collapsed: true,
              items: [
                { text: 'Signal', link: '/api/controllers/signal/signal' }
              ]
            },

            {
              text: 'Networking',
              collapsed: true,
              items: [
                { text: 'Server', link: '/api/controllers/network/server' },
                { text: 'Client', link: '/api/controllers/network/client' }
              ]
            }
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
      { icon: 'discord', link: 'https://discord.gg/cwwcZtqJAt'},
    ]
  }
})
