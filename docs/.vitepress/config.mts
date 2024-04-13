import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  head: [['link', { rel: 'icon', href: '/favicon.ico' }]],
  base: "/LuminFramework/",
  title: "Lumin Framework",
  titleTemplate: "Lumin Labs",
  description: "A blazingly fast & lightweight game framework",
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
            { text: 'Events', link: '/guides/events' },
            { text: 'Networking', link: '/guides/networking' },
            { text: 'Debugging', link: '/guides/debugging' }
          ]
        }
      ],
      '/recaps': [
        {
          text: 'Engine Recaps',
          items: [
            { text: 'February 2024', link: '/recaps/' },
            { text: 'December 2023', link: '/recaps/december2023' },
            { text: 'November 2023', link: '/recaps/november2023' },
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
                { text: 'Server', link: '/api/server' },
                { text: 'Client', link: '/api/client' }
              ]
            },

            {
              text: 'Network',
              collapsed: true,
              items: [
                { text: 'Network', link: '/api/network'},
                { text: 'ClientEvent', link: '/api/network/client/event' },
                { text: 'ServerEvent', link: '/api/network/server/event' },
                { text: 'ClientFunction', link: '/api/network/client/function' },
                { text: 'ServerFunction', link: '/api/network/server/function' }
              ]
            },

            {
              text: 'Runtime',
              collapsed: true,
              items: [
                { text: 'Runtime', link: '/api/runtime' },
                { text: 'RuntimeSettings', link: '/api/runtime/settings' },
                { text: 'RuntimeObjects', link: '/api/runtime/objects' }
              ]
            },

            { text: 'Debugger', link: '/api/debugger' },
            { text: 'Event', link: '/api/event' }
          ]
        },
      ],
    },

    outline: [2, 3],

    search: {
      provider: 'local'
    },

    editLink: {
      pattern: 'https://github.com/lumin-dev/LuminFramework/edit/main/docs/:path'
    },

    footer: {
      message: 'Built with VitePress',
      copyright: 'Copyright © 2021 - 2024 Lumin Labs'
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/lumin-dev/LuminFramework' },
      { icon: 'discord', link: 'https://discord.gg/cwwcZtqJAt' },
    ]
  }
})
