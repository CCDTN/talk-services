should = require 'should'
loader = require '../../src/loader'
{req} = require '../util'
$bughd = loader.load 'bughd'

describe 'BugHD#Webhook', ->

  it 'receive webhook', (done) ->

    req.body = {
      "user_name": "BugHD",
      "datas": [
        {
          'project_name': 'SDKTestApp',
          'project_version': '1.1.6(Build 1)',
          'issue_title': '*** -[__NSArrayI objectAtIndex:]: index 5 beyond bounds [0 .. 1]',
          'issue_stack': '0 CoreFoundation 0x0000000187391e64 <redacted> + 160',
          'created_at': '1423584178',
          "uri": "http://bughd.com/project/5620****************000c/issue/5630****************0008"
        }
      ]
    }

    req.integration = _id: 1

    $bughd.then (bughd) -> bughd.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.should.have.properties 'title', 'text', 'redirectUrl'
      message.attachments[0].data.title.should.eql 'SDKTestApp 1.1.6(Build 1)'
      message.attachments[0].data.text.should.eql '''
      TITLE: *** -[__NSArrayI objectAtIndex:]: index 5 beyond bounds [0 .. 1]
      STACK: 0 CoreFoundation 0x0000000187391e64 <redacted> + 160
      CREATED_AT: 2015-02-11 12:02:58
      '''
    .nodeify done
