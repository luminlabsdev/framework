import mermaid from "mermaid";
import { withMermaid } from "vitepress-plugin-mermaid";

export default withMermaid({
  head: [['link', { rel: 'icon', href: '/favicon.ico' }]],
  base: "/LuminFramework/",
  title: "Lumin Framework",
  titleTemplate: ":title - Lumin",
  description: "A lightning fast & lightweight game framework",
  lastUpdated: true,
  lang: 'en-us',
  mermaid: {
      fontFamily: '"Inter", sans-serif',
  },
  markdown: {
    lineNumbers: true,
  },
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
            { text: 'Controllers', link: '/guides/controllers' },
            { text: 'Workers', link: '/guides/workers' },
            { text: 'Signals', link: '/guides/signals' },
            { text: 'Networking', link: '/guides/networking' }
          ]
        }
      ],

      '/api': [
        {
          text: 'API Reference',
          items: [
            { text: 'Framework', link: '/api/' },
            { text: 'Controller', link: '/api/controller' },
            { text: 'Worker', link: '/api/worker' }
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
      { icon: 'discord', link: 'https://lumin-dev.github.io/link/discord' },
    ]
  }
})
