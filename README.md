# larning-horenso

# お試し実行

```
export SLACK_ENDPOINT="https://hooks.slack.com/services/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
export SLACK_USERNAME="おしらせBOT"
export SLACK_ICON_EMOJI=":cop:"
export SLACK_CHANNEL="#my-project"
export SLACK_MENTION="@acidlemon"
#export SLACK_MUTE_ON_NORMAL=1
#export SLACK_PASTEBIN_CMD="my-pastebin"

horenso --reporter /vagrant/slack_reporter.pl -- echo aaa
```

## 参考
https://beatsync.net/main/log20160330.html
http://www.songmu.jp/riji/entry/2016-01-05-horenso.html

