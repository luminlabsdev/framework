import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  head: [['link', { rel: 'icon', href: '/favicon.ico' }]],
  base: "/LuminFramework/",
  title: "Lumin Framework",
  titleTemplate: ":title - Lumin",
  description: "A lightning fast & lightweight game framework",
  lastUpdated: true,
  lang: 'en-us',
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      {
        text: 'Articles',
        items: [
          { text: 'Guides', link: '/guides/' },
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
            { text: 'Conventions', link: '/guides/conventions' },
            { text: 'Signals', link: '/guides/signals' },
            { text: 'Networking', link: '/guides/networking' },
            { text: 'Networking Expanded', link: '/guides/networkingexpanded' }
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
                { text: 'Network', link: '/api/network/'},
                { text: 'ClientEvent', link: '/api/network/client/event' },
                { text: 'ServerEvent', link: '/api/network/server/event' },
                { text: 'ClientFunction', link: '/api/network/client/function' },
                { text: 'ServerFunction', link: '/api/network/server/function' }
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
      pattern: 'https://github.com/lumin-dev/LuminFramework/edit/main/docs/:path'
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/lumin-dev/LuminFramework' },
      { icon: 'discord', link: 'https://discord.gg/cwwcZtqJAt' },
    ]
  }
})
