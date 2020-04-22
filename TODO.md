I need to implement these.

I'm adding them here for quick reference.

```
author @ajgdylxeifojlxpbmen3exlnsbx8buspsjh37b/ipvi=.ed25519
sequence 23
kind "example"
previous %85738f8f9a7f1b04b5329c590ebcb9e425925c6d0984089c43a022de4f19c281.sha256
timestamp 23123123123

"foo":&3f79bb7b435b05321651daefd374cdc681dc06faa65e374e38337b88ca046dea.sha256
"baz":"bar"
"my_friend":@abcdef1234567890.ed25519
"really_cool_message":%85738f8f9a7f1b04b5329c590ebcb9e425925c6d0984089c43a022de4f19c281.sha256
"baz":"whatever"

signature "3er8...LOgRdrGnuihBp4QYWYPJ5bS1Gw9weQKj9DQ==.sig.ed25519"
```

```bash
pigeon message new my_message
# => "Switched to message (kind: `my_message`)

pigeon message current # Show active log entry.
# => author: @ajgdylxeifojlxpbmen3exlnsbx8buspsjh37b/ipvi=.ed25519

pigeon message append --name=2e7a0bc3 --value=2e7a0bc3
# => \n
# => This needs to be cleaner.
# => No one likes the way it is right now.
# => We will come back to this monstrosity later.

pigeon message sign
# => author: @ajgdylxeifojlxpbmen3exlnsbx8buspsjh37b/ipvi=.ed25519
# => depth: 1
# => kind: &82244417f956ac7c599f191593f7e441a4fafa20a4158fd52e154f1dc4c8ed92.sha256
# => prev: %jvKh9yoiEJaePzoWCF1nnqpIlPgTk9FHEtqczQbvzGM=.sha256
# =>
# => &ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb.sha256:&2e7a0bc31f3c4fe6114051c3a56c8ed8a030b3b394df7d29d37648e9b8cbf54b.sha256
# =>

pigeon message find %g0Fs9yoiEJaePzoWCF1nnqpIlPgTk9FHEtqczQbvzGM=.sha256
# => author: @ajgdylxeifojlxpbmen3exlnsbx8buspsjh37b/ipvi=.ed25519
# => depth: 1
# => kind: &82244417f956ac7c599f191593f7e441a4fafa20a4158fd52e154f1dc4c8ed92.sha256
# => prev: %jvKh9yoiEJaePzoWCF1nnqpIlPgTk9FHEtqczQbvzGM=.sha256
# =>
# => &ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb.sha256:&2e7a0bc31f3c4fe6114051c3a56c8ed8a030b3b394df7d29d37648e9b8cbf54b.sha256
# =>

pigeon message find-all --author=@ajgdylxeifojlxpbmen3exlnsbx8buspsjh37b/ipvi=.ed25519 --since=1
# => author: @ajgdylxeifojlxpbmen3exlnsbx8buspsjh37b/ipvi=.ed25519
# => depth: 1
# => kind: &82244417f956ac7c599f191593f7e441a4fafa20a4158fd52e154f1dc4c8ed92.sha256
# => prev: %jvKh9yoiEJaePzoWCF1nnqpIlPgTk9FHEtqczQbvzGM=.sha256
# =>
# => &ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb.sha256:&2e7a0bc31f3c4fe6114051c3a56c8ed8a030b3b394df7d29d37648e9b8cbf54b.sha256
# =>
# => author: @ajgdylxeifojlxpbmen3exlnsbx8buspsjh37b/ipvi=.ed25519
# => depth: 2
# => kind: &82244417f956ac7c599f191593f7e441a4fafa20a4158fd52e154f1dc4c8ed92.sha256
# => prev: %jvKh9yoiEJaePzoWCF1nnqpIlPgTk9FHEtqczQbvzGM=.sha256
# =>
# => &ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb.sha256:&2e7a0bc31f3c4fe6114051c3a56c8ed8a030b3b394df7d29d37648e9b8cbf54b.sha256
# =>

pigeon peer all
# => @c8hovH5OOzNJ1SXUsIN+zI23xMcvGdEbs3ZJgzpthrw=.ed25519
# => @GOl+398b2kWeLi6+DCcU0i3AWD6vWmUtocBVYbpkpNk=.ed25519
# => @m0LEP+0NrGqu1wT8/4a3nOPuRBM+DrMpUahDZ3/cDi8=.ed25519

pigeon bundle create
# => (creates @GOl+398b2kWeLi6+DCcU0i3AWD6vWmUtocBVYbpkpNk=.ed25519.pgn)

pigeon bundle consume @GOl+398b2kWeLi6+DCcU0i3AWD6vWmUtocBVYbpkpNk=.ed25519.pgn
# =>

```
