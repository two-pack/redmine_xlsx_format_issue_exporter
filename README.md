# Redmine XLSX format issue exporter

This is Redmine plugin which exports issue list to XLSX format file.

# Project Health

[![Code Climate](https://codeclimate.com/github/two-pack/redmine_xlsx_format_issue_exporter.png)](https://codeclimate.com/github/two-pack/redmine_xlsx_format_issue_exporter) [![Stars](https://img.shields.io/redmine/plugin/stars/redmine_xlsx_format_issue_exporter.svg)](https://www.redmine.org/plugins/redmine_xlsx_format_issue_exporter)

# Requirements

- Redmine 4.2.x or higher.

# Installation

In Redmine folder,

```
$ cd plugins
$ git clone https://github.com/two-pack/redmine_xlsx_format_issue_exporter.git redmine_xlsx_format_issue_exporter
$ cd ..
$ bundle install --without test
```

Finally restart Redmine.

# Usage

- Click **XLSX** link in right-bottom of following pages.
  - Issues
  - Spent time
  - Users
  - Projects

# Acknowledgement

This plugin extracts some code from csv export function in [Redmine](http://www.redmine.org/).

# License

This plugin is released under the GPL v2 license. See LICENSE.txt for more information.

# Copyright

Copyright (C) 2014 Tatsuya Saito.
