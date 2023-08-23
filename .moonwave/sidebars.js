module.exports = {
    CanaryEngineSidebar: [
      {
        type: "doc",
        id: "intro",
        label: "About",
      },
      {
        type: "category",
        label: "Get Started",
        items: [
            "getstarted/features",
            "getstarted/comparison",
            "getstarted/questions",
            "getstarted/installation"
        ],
      },
      {
        type: "category",
        label: "Tutorials",
        items: [
            {
              type: "category",
              label: "Libraries",
              items: [
                "tutorials/libraries/uishelf",
                "tutorials/libraries/benchmark",
                "tutorials/libraries/debugger",
                "tutorials/libraries/fetch"
              ]
            },
            "tutorials/update",
            "tutorials/packages",
            "tutorials/structure",
            "tutorials/customsignals",
            "tutorials/customloader",
            "tutorials/networking",
            "tutorials/datastoring",
            "tutorials/styleguide"
        ],
      },
      {
        type: "doc",
        id: "featured",
        label: "Featured",
      },
    ],
  }