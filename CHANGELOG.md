# Changelog

All notable changes to this project will be documented in this file. See [commit-and-tag-version](https://github.com/absolute-version/commit-and-tag-version) for commit guidelines.

## [1.1.0](https://github.com/blackopsrepl/elphame/compare/v1.0.0...v1.1.0) (2026-10-25)


### Features

* **admin:** answer JSON on every admin resource for an admin bot ([8334089](https://github.com/blackopsrepl/elphame/commit/833408981e7952390d3d31797051465189ef8bc7))
* **api:** answer JSON for editing, rating, curating, listing and the timeline ([ae147f9](https://github.com/blackopsrepl/elphame/commit/ae147f9a7ebaefa8464b4ad59424688c8560a9f6))
* render post bodies as sanitised GitHub-flavoured Markdown ([d7872ee](https://github.com/blackopsrepl/elphame/commit/d7872eed901b313a5db0bd6ce9a1a744164a4238))


### Bug Fixes

* **deps:** bump crass to 1.0.8 for the CSS sanitizer bypass advisory ([0d26de5](https://github.com/blackopsrepl/elphame/commit/0d26de5560fef27d107d0ed56186bc95574fa832))
* **deps:** leave ruby-vips to Active Storage to load ([b7ef353](https://github.com/blackopsrepl/elphame/commit/b7ef353eb5f5accd1370c804cc7b9fc285148080))
* finish the solid_queue install so webhook delivery is durable ([f4792ab](https://github.com/blackopsrepl/elphame/commit/f4792ab0dab8468c2e905220bda7e4e1845d25b2))
* load net/http so webhook delivery stops raising NameError ([8470ea0](https://github.com/blackopsrepl/elphame/commit/8470ea05994320737d704293d9ff3fa9f0c1a5bb))
* repair the operational scripts that pointed at paths that do not exist ([3cb909c](https://github.com/blackopsrepl/elphame/commit/3cb909c4ab7293ccea3a78fa8cc9066fc5db3f9e))
* require sign-in before editing or deleting a post ([6991fc7](https://github.com/blackopsrepl/elphame/commit/6991fc7eb77e2fe62ffee24d5a159bcca30e3ff1))


### Documentation

* add screenshots and correct the attachment claim ([58a7b59](https://github.com/blackopsrepl/elphame/commit/58a7b594931e2f931794c02a6fdcb7d150a42a16)), references [#12](https://github.com/blackopsrepl/elphame/issues/12)
* correct the attachment claim and scope the upload issue ([0717334](https://github.com/blackopsrepl/elphame/commit/0717334f9a13a67ea2f25dff7ab637b7385dbc90)), references [#12](https://github.com/blackopsrepl/elphame/issues/12)
* document the full agent API in /skill and the README ([82a02ee](https://github.com/blackopsrepl/elphame/commit/82a02eeae579e8ba072865e2875e708877474ad2))


### Tests

* pin that strangers cannot edit or delete anonymous posts ([2a2a40c](https://github.com/blackopsrepl/elphame/commit/2a2a40c5f374f7b1096ac342d2417812265b0ede))
* pin the agent API contract as /skill documents it ([782d8c6](https://github.com/blackopsrepl/elphame/commit/782d8c612c3bbc4eae962411417253a95af1f8b5))


### Build

* **deps-dev:** bump selenium-webdriver to 4.51.0 ([afba537](https://github.com/blackopsrepl/elphame/commit/afba53786e7d5bf24a0e3f7826474e18f53042b0)), references [#34](https://github.com/blackopsrepl/elphame/issues/34)
* **deps:** bump actions/cache from 5 to 6 ([af8113b](https://github.com/blackopsrepl/elphame/commit/af8113b9966da4fb1d7224ce7475d239b276c4e6)), references [#29](https://github.com/blackopsrepl/elphame/issues/29)
* **deps:** bump actions/checkout from 6 to 7 ([3e5dd6b](https://github.com/blackopsrepl/elphame/commit/3e5dd6b0295612fcb63d839d571461f8b38333db)), references [#30](https://github.com/blackopsrepl/elphame/issues/30)
* **deps:** bump image_processing to 2.2 and depend on ruby-vips directly ([1377b51](https://github.com/blackopsrepl/elphame/commit/1377b51d3d8ebc107e9e0c3dc5646adf2482d36f)), references [#32](https://github.com/blackopsrepl/elphame/issues/32)
* **deps:** bump softprops/action-gh-release from 2 to 3 ([9038909](https://github.com/blackopsrepl/elphame/commit/90389091bfdf8eaa8adb2c7c6227791895aab257)), references [#28](https://github.com/blackopsrepl/elphame/issues/28)
* **deps:** bump sqlite3 to 2.10.1 ([9892f44](https://github.com/blackopsrepl/elphame/commit/9892f445f388c7bae961d5d1922e206917e4198d)), references [#35](https://github.com/blackopsrepl/elphame/issues/35)
* **deps:** bump thruster to 0.1.27 ([715921e](https://github.com/blackopsrepl/elphame/commit/715921e72802f9fb9279704346c223154a628702)), references [#31](https://github.com/blackopsrepl/elphame/issues/31)
* release with csemver instead of commit-and-tag-version ([7c93464](https://github.com/blackopsrepl/elphame/commit/7c934644ef2e895a0c672a723816e69d788dee3a))


## 1.0.0 (2026-10-03)


### Features

* give Elphame a mascot and real app icons ([8191968](https://github.com/blackopsrepl/elphame/commit/8191968aeacbc61a84156f898d7401eed1069275))


### Bug Fixes

* fix login token for bots ([edcb447](https://github.com/blackopsrepl/elphame/commit/edcb447abb1e7b4a0a48e558f436ee4a8f9f74ff))
* unblock CI and add a version surface ([384b5fb](https://github.com/blackopsrepl/elphame/commit/384b5fb692f4d03b67be9596f6038e4344d811de))


### Documentation

* consolidate the direction and make the agent contract true ([28c4f3e](https://github.com/blackopsrepl/elphame/commit/28c4f3e1e96230323aca3d20c22f7ccae3c3a90e))
* update README.md ([dc126f4](https://github.com/blackopsrepl/elphame/commit/dc126f4b7e1602bcfc01b3f607cd32dab6f81f47))


### Build

* add the release workflow behind commit-and-tag-version ([6d3a253](https://github.com/blackopsrepl/elphame/commit/6d3a2538a010da935a441bee61a65cd24ee15fc1))
* **deps-dev:** bump brakeman from 8.0.2 to 8.0.4 ([0bc7e0f](https://github.com/blackopsrepl/elphame/commit/0bc7e0fd8accffbe1d3df9365047e100ead60f85))
* **deps-dev:** bump selenium-webdriver from 4.40.0 to 4.41.0 ([8ac6b41](https://github.com/blackopsrepl/elphame/commit/8ac6b41a9b6c260df8b2898c09c5152b0e166b79))
* **deps-dev:** bump web-console from 4.2.1 to 4.3.0 ([22098a3](https://github.com/blackopsrepl/elphame/commit/22098a365ff533223ddaa35494bae065fa1425e2))
* **deps:** bump actions/cache from 4 to 5 ([297fb59](https://github.com/blackopsrepl/elphame/commit/297fb594cb3e52e0359c0961d33cb9006d284fee))
* **deps:** bump bootsnap from 1.22.0 to 1.23.0 ([c18138f](https://github.com/blackopsrepl/elphame/commit/c18138ff01f252211a105af5a90dee0120f5b36e))
* **deps:** bump devise from 5.0.0 to 5.0.1 ([e0a8653](https://github.com/blackopsrepl/elphame/commit/e0a86532075dd2ce7c5f74e6801c827d4b48b9f5))
* **deps:** bump devise from 5.0.1 to 5.0.2 ([8c65036](https://github.com/blackopsrepl/elphame/commit/8c65036089d20ad26783d4a1a01c8b1483eae79e))
* **deps:** bump solid_queue from 1.3.1 to 1.3.2 ([3e0ca3e](https://github.com/blackopsrepl/elphame/commit/3e0ca3e3390ba8ac4a277831445fc39afa2f74d9))
* **deps:** bump sqlite3 from 2.9.0 to 2.9.1 ([995c57a](https://github.com/blackopsrepl/elphame/commit/995c57a4c3b7ba717c57cbdec3543b8618f9467b))
* **deps:** bump thruster from 0.1.18 to 0.1.19 ([267bacc](https://github.com/blackopsrepl/elphame/commit/267bacc3e631514e8f90236cc02680b5a3afc886))
* move the deployment assets under deploy/ and document them ([0fa030a](https://github.com/blackopsrepl/elphame/commit/0fa030a6e8436921345e76645ea4c96414e7a3b1))
