import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  head: [['link', { rel: 'icon', href: 'static/images/logo.png' }]],
  base: "/CanaryEngine/",
  title: "CanaryEngine",
  titleTemplate: "Canary Development",
  description: "A lightweight and blazingly fast framework",
  lastUpdated: true,
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      {
        text: 'Guides',
        items: [
          { text: 'Get Started', link: '/getstarted/intro'},
          { text: 'Usage', link: '/tutorials/update' },
          { text: 'Libraries', link: '/tutorials/libraries/benchmark' }
        ]
      },

      {
        text: 'Articles',
        items: [
          { text: 'Blogs', link: '/blog/enginerecaps/enginerecap-september2023' },
          { text: 'Featured', link: '/featured' }
        ]
      },

      {
        text: 'API',
        items: [
          { text: 'Engine', link: '/api/engine/canaryengine' },
          { text: 'Library', link: '/api/libraries/' }
        ]
      },

      { text: 'Changelog', link: '/changelog'}
    ],

    sidebar: {
      '/tutorials/libraries/': [
        {
          text: 'Libraries',
          items: [
            { text: 'Benchmark', link: '/tutorials/libraries/benchmark' },
            { text: 'Debugger', link: '/tutorials/libraries/debugger' },
            { text: 'UIShelf', link: '/tutorials/libraries/uishelf' }
          ]
        }
      ],
      '/getstarted': [
        {
          text: 'Get Started',
          items: [
            { text: 'Introduction', link: '/getstarted/intro' },
            { text: 'Features', link: '/getstarted/features' },
            { text: 'Comparison', link: '/getstarted/comparison' },
            { text: 'Installation', link: '/getstarted/installation' },
            { text: 'FAQ', link: '/getstarted/faq' }
          ]
        }
      ],
      '/tutorials': [
        {
          text: 'Management',
          items: [
            { text: 'Update', link: '/tutorials/update' },
            { text: 'Packages', link: '/tutorials/packages' },
            { text: 'Structure', link: '/tutorials/structure' },
            { text: 'Style Guide', link: '/tutorials/styleguide' },
          ]
        },

        {
          text: 'Engine',
          items: [
            { text: 'Signals', link: 'tutorials/signals' },
            { text: 'Networking', link: 'tutorials/networking' },
            { text: 'Data Management', link: 'tutorials/datastoring' },
            { text: 'Loading Screen', link: 'tutorials/customloader' }
          ]
        }
      ],
      '/blog': [
        {
          text: 'Engine Recaps',
          items: [
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

      '/api/engine': [
        {
          text: 'Canary',
          items: [
            {
              text: 'Framework',
              items: [
                { text: 'CanaryEngine', link: '/api/engine/canaryengine' },
                { text: 'CanaryEngineServer', link: '/api/engine/canaryengineserver' },
                { text: 'CanaryEngineClient', link: '/api/engine/canaryengineclient' },
                { text: 'CanaryEngineReplicated', link: '/api/engine/canaryenginereplicated'}
              ]
            },

            {
              text: 'Dependencies',
              items: [
                { text: 'EngineDebugger', link: '/blog/enginerecaps/enginerecap-september2023' },
                { text: 'EngineLoader', link: '/blog/enginerecaps/enginerecap-august2023' },
                { text: 'EngineTypes', link: '/blog/enginerecaps/enginerecap-july2023' }
              ]
            },

            {
              text: 'Runtime',
              items: [
                { text: 'EngineRuntime', link: '/blog/enginerecaps/enginerecap-september2023' },
                { text: 'EngineRuntimeContext', link: '/blog/enginerecaps/enginerecap-august2023' },
                { text: 'EngineRuntimeSettings', link: '/blog/enginerecaps/enginerecap-july2023' }
              ]
            }
          ]
        },
      ]
    },

    search: {
      provider: 'local'
    },

    footer: {
      message: 'Built with VitePress',
      copyright: 'Copyright © 2021 - 2023 Canary Development'
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/canary-development/CanaryEngine' },
      { icon: 'discord', link: 'https://discord.gg/cwwcZtqJAt'}
    ]
  }
})
