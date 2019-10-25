<p align="center">
  <a href="https://github.com/joelpurra/jqnpm"><img src="https://raw.githubusercontent.com/joelpurra/jqnpm/master/resources/logotype/penrose-triangle.svg?sanitize=true" alt="jqnpm logotype, a Penrose triangle" width="100" border="0" /></a>
</p>

# [<%=FULL_PACKAGE_NAME%>](https://github.com/<%=GITHUB_USERNAME%>/<%=FULL_PACKAGE_NAME%>)

<%=ONE_SENTENCE_DESCRIPTION%>

This is a package for the command-line JSON processor [`jq`](https://stedolan.github.io/jq/). Install the package in your jq project/package directory with [`jqnpm`](https://github.com/joelpurra/jqnpm):

```bash
jqnpm install joelpurra/<%=FULL_PACKAGE_NAME%>
```



## Usage


```jq
import "joelpurra/<%=FULL_PACKAGE_NAME%>" as <%=PACKAGE_ALIAS%>;

# <%=PACKAGE_ALIAS%>::myFirstFunction
"World" | <%=PACKAGE_ALIAS%>::myFirstFunction		# "Hello World!"
```



---

## License
Copyright (c) <%=CURRENT_YEAR%> <%=FULL_NAME%> <<%=USER_HOMEPAGE_URL%>>
All rights reserved.

When using **<%=FULL_PACKAGE_NAME%>**, comply to the MIT license. Please see the LICENSE file for details.
