---
title: "SIP Extension for Model Context Protocol (MCP)"
abbrev: "SIP MCP Extension"
docname: draft-howe-sipcore-mcp-extension-00
category: info
ipr: trust200902
date: 2025-09-28

author:
 -
    fullname: Thomas McCarthy-Howe
    organization: VCONIC
    email: thomas@vconic.com

normative:
  RFC3261:
  RFC2119:
  RFC8174:
  RFC3264:
  RFC5234:
  RFC3711:
  RFC4145:
  RFC4975:
  RFC4976:
  RFC5764:
  RFC8866:
  RFC3550:

informative:
  RFC3428:
  RFC7118:
  RFC7587:
  RFC6809:
  RFC5727:
  RFC5922:

--- abstract

This document specifies a Session Initiation Protocol (SIP) {{RFC3261}}
extension to advertise support for, negotiate, and carry the Model
Context Protocol (MCP).  It defines: (1) a new SIP option-tag ("mcp"),
(2) new header fields for capability advertisement and selection,
(3) Contact feature-capability parameters for registration-time
discovery, and (4) the "application/mcp+json" media type. MCP payloads
can be exchanged during session establishment and mid-dialog using
INVITE/200 (Offer/Answer), MESSAGE, and INFO.

--- middle

# Introduction

The Model Context Protocol (MCP) is an application protocol for structured interaction with tools and agents. While MCP enables powerful AI agent capabilities, real-world production deployments have revealed significant transport-layer limitations that impact reliability, performance, and user experience.

## Problem Statement: MCP Transport Layer Failures

Current MCP implementations encounter measurable failures in production environments, particularly affecting latency, reliability, and scalability:

**Performance Impact**: Production deployments show MCP adds 300–800ms latency when invoked synchronously in critical transaction paths, with developers reporting this "destroys user experience" in customer-facing systems. P99 latency spikes cause substantial delays for the slowest 1% of transactions, leading to user frustration and cascading timeouts in orchestration flows.

**Reliability Issues**: Production scenarios report recovery failure rates of 20–30% without explicit error handling at the transport layer. STDIO pipes break silently, HTTP connection pools saturate under high load, and WebSocket connections disconnect-reconnect repeatedly, causing agents to lose context or fail mid-task.

**Scalability Limitations**: Connecting multiple tool servers (e.g., Github, Linear, Playwright) can consume over 60,000 tokens of context capacity, leading to expensive API overages and poor agent performance. Each MCP server operates in isolation with no shared state, forcing users to repeat steps or lose workflow progress between sessions.

**Developer Experience**: The official documentation for developing custom transports is lacking, the concepts section is complex, and the Python SDK lacks foundational interfaces, creating significant barriers to adoption and reliable implementation.

### Summary of MCP Transport Pain Points

| Failure Mode/Metric           | Current MCP Impact                    | Real-World Evidence                     |
|-------------------------------|---------------------------------------|-----------------------------------------|
| High Latency (300–800ms)      | Synchronous MCP in transaction flows  | "Destroys user experience" in customer-facing systems |
| Connection Instability        | STDIO pipes, WebSocket disconnects    | "STDIO pipes break silently", 20-30% recovery failure rates |
| Context/Token Bloat           | Multiple tool servers in context      | "60,000 tokens consumed", API cost surge |
| Isolation, No Shared State    | Multi-step workflows                  | "Users repeat steps or lose workflow progress" |
| Lack of Documentation         | Custom transport implementation       | "Official documentation ... lacking" |
| P99 Latency Spikes           | Tail latency in orchestration flows   | Cascading timeouts, user frustration |

## SIP as a Solution

SIP is widely deployed for rendezvous, session negotiation, and inter-domain federation. This document defines a minimal, backward-compatible SIP extension enabling MCP-aware endpoints to discover each other and exchange MCP messages using existing SIP methods, addressing the transport-layer limitations identified in current MCP deployments.

## Use Cases Addressed

This SIP extension for MCP addresses both general AI agent communication needs and specific scenarios that are uniquely enabled by SIP's architectural capabilities.

### General MCP Use Cases Enhanced by SIP

**Enterprise AI Agent Orchestration**: Organizations deploying multiple specialized AI agents (document processing, customer service, data analysis) require reliable, low-latency communication between agents. SIP's session management eliminates the 300–800ms latency penalties documented in current HTTP-based MCP deployments, while its proxy infrastructure enables intelligent routing based on agent capabilities.

**Multi-Modal AI Interactions**: Modern AI applications increasingly combine text, voice, and visual processing. SIP's media negotiation framework allows simultaneous audio streams (for voice interaction) and MCP data exchange (for tool calls and structured responses), enabling natural voice-guided AI workflows that are impractical with current MCP transports.

**Cross-Organizational AI Collaboration**: AI agents from different organizations need to collaborate while respecting security boundaries and policies. SIP's mature inter-domain federation model provides the trust management and policy enforcement mechanisms necessary for secure cross-organizational agent interactions.

**High-Availability AI Services**: Production AI systems require robust failover and load distribution. SIP's registration-based discovery provides 60-120 second agent availability updates (vs. 5-10 minutes with DNS), while proxy-based load balancing eliminates the single points of failure common in current MCP deployments.

### SIP-Unique Use Cases

**Voice-First AI Agent Interactions**: Call centers, voice assistants, and telephony-integrated AI systems require tight coordination between voice streams and AI tool execution. SIP's native audio handling combined with MCP tool calls enables scenarios like:
- Customer service agents that can simultaneously talk to customers and execute backend tool calls
- Voice-controlled document processing where spoken commands trigger complex AI workflows
- Real-time language translation with tool-assisted context lookup

**Telecommunications-Integrated AI**: Existing SIP infrastructure in telecommunications and enterprise environments can be extended to support AI agents without requiring parallel communication systems:
- PBX systems can route calls to AI agents based on detected capabilities
- Existing SIP monitoring and billing systems can track AI agent usage
- Telecom-grade reliability and security models apply to AI agent communications

**Session-Aware AI Workflows**: Long-running AI processes that maintain conversational context across multiple interactions benefit from SIP's dialog management:
- Multi-step document review processes where agents maintain state across sessions
- Collaborative AI workflows where multiple agents contribute to extended tasks
- Educational AI tutors that maintain learning context across multiple sessions

**Multimedia AI Tool Calling**: The combination of MCP with MSRP enables sophisticated multimedia AI interactions:
- Image analysis agents that receive binary image data without base64 encoding overhead
- Document processing agents that can stream large generated reports in real-time
- Creative AI agents that exchange multimedia assets (images, audio, video) as part of tool calls

## Architectural Justification

### Why SIP for MCP Transport?

While MCP can operate over various transports including HTTP and WebSocket, SIP provides unique architectural advantages that make it particularly suitable for agent-to-agent communication scenarios:

**Session Management and State**: SIP's inherent session model aligns naturally with MCP's stateful conversation paradigm. Unlike stateless HTTP interactions, SIP dialogs provide persistent session context that can maintain MCP conversation state, tool availability, and capability negotiations throughout the interaction lifecycle.

**Rendezvous and Discovery**: SIP's registration and location services enable dynamic discovery of MCP-capable agents across network boundaries with superior performance characteristics compared to DNS-based alternatives. SIP registrations provide programmable TTLs (60-3600+ seconds) with immediate effect, enabling rapid agent deployment and failover scenarios that are impractical with DNS propagation delays (typically 300+ seconds).

**Inter-domain Federation**: SIP's mature federation model allows MCP interactions to span organizational boundaries securely. This enables scenarios where agents from different organizations can collaborate while respecting domain policies and security boundaries.

### Backward Compatibility and Incremental Deployment

This extension supports incremental deployment:
- Existing SIP infrastructure does not require modification.
- Endpoints that are not MCP-aware will gracefully reject MCP requests using standard SIP error responses.
- MCP-capable endpoints can fall back to alternative transport methods if SIP peers do not support the extension.
- The extension does not alter core SIP semantics or existing header fields.

# Model Context Protocol (MCP) — Purpose, Architecture, Capabilities

This section orients SIP implementers to MCP. It is informative and
summarizes the MCP model at a level sufficient to map MCP onto SIP
signaling and mid-dialog exchanges.

## Purpose (non-normative)

MCP is an open protocol that standardizes how AI applications connect
to external data and tools. It separates "context providers" from host
applications so that an AI app can compose capabilities from many
independent MCP servers while preserving clear security and consent
boundaries. At its core, MCP uses JSON‑RPC 2.0 messages to exchange
context, discover capabilities, and invoke operations in a uniform way.

## Architecture (non-normative)

MCP follows a host–client–server pattern:

* **MCP Host:** the AI application (e.g., IDE, desktop app, chat system)
  that manages one or more MCP clients.
* **MCP Client:** a connector inside the host that maintains a dedicated
  1:1 connection to a single MCP server.
* **MCP Server:** a program that exposes context (data) and actions
  (tools/prompts) to clients.

The protocol has two layers:

* **Data layer (inner):** a JSON‑RPC 2.0 based protocol defining message
  structure, lifecycle (initialization, capability negotiation),
  and the primitives each side offers.
* **Transport layer (outer):** the channel over which JSON‑RPC messages
  flow. MCP commonly uses two transports:
  - **stdio:** local process IPC over stdin/stdout, typically for
    "local" servers launched by the host.
  - **Streamable HTTP:** remote servers communicating via HTTP POSTs,
    with optional Server‑Sent Events (SSE) for streaming and
    server‑initiated messages.

Sessions are stateful: during initialization, client and server
negotiate protocol version and capabilities and may bind a session
identifier that is echoed on subsequent transport operations.

## Capabilities and Primitives (non-normative)

MCP defines structured "primitives" that either side can expose:

* **Server‑side primitives**
  - **Resources:** URI‑identified data the client can list and read
    (text or binary), optionally subscribe to for updates, and receive
    change notifications for.
  - **Tools:** executable functions with JSON Schema‑described inputs;
    clients discover tools and invoke them to perform actions such as
    database queries or API calls.
  - **Prompts:** reusable, parameterized prompt templates that hosts can
    fetch and render for users or models.
* **Client‑side primitives**
  - **Sampling:** a server can request the host to obtain model
    completions (i.e., to "call the LLM") without bundling a model
    SDK inside the server.
  - **Elicitation and logging:** optional utilities for user interaction
    and diagnostics.

MCP also includes cross‑cutting utilities for configuration, progress
tracking, cancellation, and notifications. Together, these enable
dynamic discovery, composition across multiple servers, and fine‑grained
control over what data and actions are available to a given conversation.

# Conventions and Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED",
"MAY", and "OPTIONAL" in this document are to be interpreted as
described in BCP 14 {{RFC2119}} {{RFC8174}} when, and only when, they
appear in all capitals, as shown here.

ABNF is per {{RFC5234}}. SIP terms are per {{RFC3261}}. Feature-capability
indicators follow {{RFC6809}}.

## Applicability Statement

This section defines the intended scope and limitations of this SIP extension for MCP transport, as required for Informational RFCs per {{RFC5727}}.

### Intended Use Cases

This extension is designed for the following specific scenarios:

**Agent-to-Agent Communication**: AI agents that need to exchange structured tool calls, context, and capabilities while maintaining session state and supporting real-time interaction patterns.

**Enterprise AI Integration**: Organizations deploying multiple AI systems that require secure, policy-controlled inter-agent communication across network boundaries with audit trails and compliance monitoring.

**Multi-modal AI Applications**: Systems combining voice interaction with structured data exchange, where SIP's media negotiation capabilities enable coordinated audio and MCP data streams.

**Federated AI Networks**: Cross-organizational AI collaboration requiring SIP's mature inter-domain routing, security, and federation capabilities.

### Appropriate Deployment Environments

**Controlled Networks**: Enterprise environments with existing SIP infrastructure where administrators can manage MCP-capable endpoints and configure appropriate security policies.

**Federated Deployments**: Inter-organizational scenarios where SIP's domain-based routing and security model provides necessary trust boundaries and policy enforcement.

**Real-time Applications**: Use cases requiring low-latency session establishment, capability negotiation, and the ability to correlate voice and data streams temporally.

### Limitations and Constraints

**Not for General Internet Use**: This extension is not intended for general Internet deployment where endpoints cannot be trusted or where security policies cannot be enforced. The combination of AI capabilities with network protocols requires careful security consideration.

**Requires SIP Infrastructure**: Organizations without existing SIP infrastructure should carefully evaluate whether the benefits justify the deployment complexity compared to HTTP/WebSocket alternatives.

**Limited to MCP Protocol**: This extension specifically supports MCP and is not a general-purpose AI protocol transport mechanism. Other AI protocols would require separate extensions.

**Security Dependencies**: The security of MCP-over-SIP depends entirely on proper TLS deployment, certificate management, and SIP security best practices. Improper security configuration could expose sensitive AI capabilities and data.

# Overview

* **Discovery:** endpoints advertise MCP support and granular capabilities
  during REGISTER using Contact feature-caps and/or in responses.
* **Negotiation:** endpoints indicate desire/requirement for MCP using
  the "mcp" option-tag, and exchange an initial MCP offer/answer in
  INVITE/200 OK bodies as `application/mcp+json`.
* **Exchange:** subsequent MCP messages are carried in SIP MESSAGE or
  INFO bodies with `Content-Type: application/mcp+json`. MSRP or a
  SIP-negotiated WebSocket ({{RFC7118}}) MAY be used for bulk transport.
* **Multimodal:** the same dialog MAY negotiate RTP audio streams alongside
  an MSRP session used to carry MCP; see Section 7.6.

## Backward Compatibility

This extension is designed for seamless backward compatibility with existing SIP infrastructure:

* **Legacy SIP Implementations:** Existing SIP user agents, proxies, and registrars that do not implement this extension continue to operate normally. The extension introduces no changes to core SIP semantics, message formats, or processing rules.

* **Graceful Degradation:** When one party does not support MCP:
  - If MCP is optional (Supported: mcp), the session proceeds as a standard SIP session without MCP functionality
  - If MCP is required (Require: mcp), non-supporting endpoints respond with 420 (Bad Extension) per {{RFC3261}}, allowing the caller to retry without MCP
  - Unknown header fields (MCP-Capabilities, MCP-Select) are ignored per {{RFC3261}} Section 7.4.1

* **Incremental Deployment:** Organizations can deploy MCP-capable endpoints gradually without requiring network-wide upgrades. Mixed environments with both MCP-aware and legacy endpoints operate without disruption.

# SIP Extensions

## Option-Tag: mcp

**Note:** As an Informational RFC, this document does not register the "mcp" option tag (which requires Standards Action per {{RFC5727}}). Implementations SHOULD use experimental option tags such as "x-mcp" or organization-specific variants until a Standards Track specification is available.

The option-tag indicates support for this specification:

* A UAC MAY include the option tag in a Require header when MCP support is
  mandatory for the request; proxies/UAS that do not understand
  the tag will respond with 420 (Bad Extension).
* A UAC or UAS MAY include the option tag in Supported to advertise support.

## Header: MCP-Capabilities

The MCP-Capabilities header field conveys a concise, serializable
summary of available MCP tools/functions and versions.

Example (folded for display):

~~~
MCP-Capabilities: ver=1.0; tools="summarize@2,sql.query@1";
  schemas="urn:ex:doc:1,urn:ex:customer:3"
~~~

Semantics:
* Endpoints MAY include MCP-Capabilities in REGISTER, INVITE,
  200 OK, and OPTIONS.
* Parsable by intermediaries for routing hints; see Section 7.1.

**Backward Compatibility:** Per {{RFC3261}} Section 7.4.1, SIP implementations that do not recognize this header field MUST ignore it. This ensures that existing SIP infrastructure continues to function normally when processing messages containing MCP-Capabilities headers.

## Header: MCP-Select

The MCP-Select header communicates a caller's desired subset or mode
of MCP operation (e.g., chosen tool bundle, schemas, or role).

Example:

~~~
MCP-Select: tools="summarize@2"; role="assistant"; policy="safe"
~~~

Semantics:
* MAY appear in INVITE or mid-dialog requests (e.g., UPDATE, INFO)
  to request a change to the active MCP capability set.

**Backward Compatibility:** Like MCP-Capabilities, this header field is ignored by SIP implementations that do not recognize it, ensuring no impact on existing SIP processing.

## Contact Feature-Caps: +mcp, +mcp.ver, +mcp.cap

This document defines feature-capability indicators per {{RFC6809}}:

~~~
+mcp           ; boolean presence indicates MCP support
+mcp.ver       ; token, MCP major.minor version (e.g., "1.0")
+mcp.cap       ; quoted-string; capability token set
~~~

Example Contact header parameter usage in REGISTER:

~~~
Contact: <sip:alice@ua.example>;expires=3600; +mcp; +mcp.ver="1.0";
  +mcp.cap="summarize@2,sql.query@1,urn:ex:doc:1"
~~~

**Backward Compatibility:** Feature-capability indicators follow {{RFC6809}} semantics. SIP registrars and proxies that do not understand these parameters treat them as opaque Contact header parameters and preserve them during registration processing. This allows MCP-aware endpoints to discover each other even in mixed environments with legacy infrastructure.

# Payload Format: application/mcp+json

**Media type:** `application/mcp+json`  
**Encoding:** UTF-8

Two forms are defined:

**(a) Native MCP message:** the body is a single MCP JSON‑RPC 2.0 request,
response, or notification as defined by the MCP specification.

**(b) SIP negotiation envelope (Offer/Answer only):** the body is a small
JSON object used to pre‑negotiate MCP roles/capabilities within SIP
INVITE/200. Example:

~~~ json
{
  "mcp_version": "1.0",
  "type": "offer|answer",
  "conversation": "uuid",
  "payload": {
    "role": "caller|callee",
    "tools": ["name@ver", "..."],
    "schemas": ["urn:..."]
  }
}
~~~

Endpoints MUST accept (a). Support for (b) is OPTIONAL and only valid
during session establishment to prime subsequent MCP exchanges.

# Protocol Operation

## Registration-Time Advertisement

UAs supporting MCP SHOULD advertise via Contact feature-caps (+mcp,
+mcp.ver, +mcp.cap). Registrars MAY index these for capability-based
routing. Proxies MUST treat these parameters as opaque hints and MUST
NOT modify them.

### Registration Performance Characteristics

MCP-capable agents SHOULD optimize registration refresh intervals based on their operational characteristics:

**Ephemeral Agents** (short-lived, experimental, or development agents):
* SHOULD use registration intervals of 60-300 seconds
* MUST be prepared for immediate de-registration upon shutdown
* MAY use shorter intervals (60-120 seconds) for rapid discovery requirements

**Stable Production Agents** (long-running, production services):
* SHOULD use registration intervals of 1800-3600 seconds (30-60 minutes)
* MUST implement graceful shutdown with explicit de-registration
* MAY extend intervals up to 7200 seconds (2 hours) for highly stable services

This registration-based discovery provides significant performance advantages over DNS-based alternatives:
* New agent availability: 60-300 seconds vs. 300-3600 seconds (DNS TTL)
* Failed agent detection: 60-1800 seconds vs. 300-3600+ seconds (DNS cache expiration)
* Capability updates: Immediate upon registration vs. DNS TTL-dependent
* Cross-domain discovery: Leverages existing SIP peering vs. global DNS propagation delays

## Session Establishment (Offer/Answer)

A UAC desiring MCP:
* Includes Supported: mcp (and optionally Require: mcp).
* Sends INVITE with an `application/mcp+json` body of type "offer"
  describing initial MCP role, tools, and schemas (Section 6).

A UAS accepting MCP:
* Includes Supported: mcp in 200 OK.
* Returns `application/mcp+json` of type "answer" with confirmed
  capabilities or reduced set.

If MCP is rejected but the call proceeds, the UAS omits Supported: mcp
and returns 415/488 if a body was required.

## Mid-Dialog Exchange (MESSAGE/INFO)

* Short transactional MCP messages MAY be sent using SIP MESSAGE
  (out-of-dialog or in-dialog). Reliable mid-dialog signaling MAY use
  SIP INFO. Bodies MUST be `application/mcp+json`.
* For large or streaming exchanges, endpoints MAY negotiate MSRP
  ({{RFC4975}}/{{RFC4976}}) or SIP WebSocket ({{RFC7118}}) and then tunnel MCP at
  that layer; negotiation is out of scope.

## Error Handling

* 420 (Bad Extension) if Require: mcp is present and unsupported.
* 415 (Unsupported Media Type) if `Content-Type: application/mcp+json`
  is not supported.
* Within MCP payloads, application-level errors are signaled using
  MCP's native error members; SIP error codes SHOULD map where
  practical (e.g., 403 for policy, 488 for not acceptable here).

## Graceful Degradation Scenarios

This section describes specific behaviors when MCP support is asymmetric or unavailable:

**Scenario 1: UAC supports MCP, UAS does not**
* UAC sends INVITE with Supported: mcp (optional)
* UAS processes INVITE normally, ignoring MCP-related headers
* UAS responds with 200 OK without Supported: mcp
* UAC detects lack of MCP support and proceeds with standard SIP session
* No MCP functionality is available, but the session succeeds

**Scenario 2: UAC requires MCP, UAS does not support it**
* UAC sends INVITE with Require: mcp
* UAS responds with 420 (Bad Extension) listing "mcp" in Unsupported header
* UAC MAY retry the request without Require: mcp if fallback is acceptable
* If no retry occurs, the session fails cleanly with standard SIP error handling

## Multimodal Operation (Audio + MSRP)

This section specifies how an MCP-enabled dialog can carry interactive
audio alongside an MSRP-based control/data channel for MCP.

### Goals and Scope

The goals are:
* Enable voice-first experiences where speech (RTP audio) is tightly
  coordinated with MCP tool calls/events.
* Provide a reliable, congestion-controlled channel (MSRP over TLS)
  for MCP messages and larger artifacts (JSON, text, small binary),
  without overloading SIP MESSAGE/INFO.

### Media Negotiation with SDP

Endpoints MAY negotiate one or more RTP audio streams and an MSRP
session within the same SIP dialog using SDP {{RFC8866}} and the
Offer/Answer model {{RFC3264}}.

* **Audio:**
  - UAs SHOULD negotiate SRTP {{RFC3711}}. DTLS‑SRTP {{RFC5764}} is
    RECOMMENDED for keying. Codec choice is out of scope; Opus
    {{RFC7587}} is a reasonable default.
  - Standard SDP attributes (e.g., `a=rtpmap`, `a=fmtp`, `a=ptime`,
    `a=sendonly/recvonly/inactive`) apply unchanged.

* **MSRP:**
  - MSRP MUST be negotiated via an SDP `m=message` line per {{RFC4975}}.
  - TLS for MSRP (msrps) is RECOMMENDED. TCP connection roles MUST be
    signaled using `a=setup` and `a=connection` per {{RFC4145}}.
  - The MSRP media description SHOULD include:

~~~
a=path: <msrp(s) URI>
a=accept-types: application/mcp+json
~~~

Additional accepted types (e.g., `text/plain`, `image/*`) MAY be
listed according to application needs.

### Binding MCP to MSRP

Once negotiated, MCP messages SHOULD be carried over MSRP with
`Content-Type: application/mcp+json`. Message bodies MAY be chunked
and reliably delivered by MSRP. For very small, latency‑sensitive
notifications, SIP INFO/MESSAGE MAY still be used, but endpoints
SHOULD prefer the MSRP channel for sustained exchanges.

MSRP sessions carrying MCP are long‑lived and bidirectional (`a=sendrecv`).
Either party MAY initiate MCP JSON‑RPC requests.

### Timing and Synchronization

Implementations often need to correlate MCP events (e.g., VAD start,
tool results) with audio time.

* **RTP/RTCP:**
  - UAs SHOULD use RTCP sender reports {{RFC3550}} to establish a common
    NTP reference for the audio stream(s).

* **Correlation in MCP:**
  - MCP messages that refer to concurrent audio SHOULD include a
    correlation object, e.g.:

~~~ json
{ "jsonrpc":"2.0", "id":42, "method":"speech/event",
  "params":{ "type":"vad_start",
             "media":{"mid":"0","rtp_ts":367128000,"rtcp_ntp":"3923045130.125"} } }
~~~

The `"mid"` (if used) maps to the SDP media id or m-line order. The
`"rtcp_ntp"` value SHOULD be derived from the most recent RTCP SR.
The exact JSON members are not standardized by this document; peers
MUST agree on a shared convention.

# ABNF

Using the ABNF of {{RFC5234}} and header field grammar of {{RFC3261}}:

~~~
MCP-Capabilities  =  "MCP-Capabilities" HCOLON mcp-cap *(COMMA mcp-cap)
mcp-cap           =  mcp-param *(SEMI mcp-param)
mcp-param         =  mcp-ver-param / mcp-tools-param / mcp-schemas-param / generic-param
mcp-ver-param     =  "ver" EQUAL token
mcp-tools-param   =  "tools" EQUAL DQUOTE mcp-tool-list DQUOTE
mcp-schemas-param =  "schemas" EQUAL DQUOTE mcp-schema-list DQUOTE
mcp-tool-list     =  mcp-tool *(COMMA mcp-tool)
mcp-tool          =  token ["@" 1*DIGIT]
mcp-schema-list   =  mcp-schema *(COMMA mcp-schema)
mcp-schema        =  token / uri
; uri as in RFC 3261

MCP-Select        =  "MCP-Select" HCOLON mcp-sel *(SEMI mcp-sel-param)
mcp-sel           =  1#( mcp-tools-param / mcp-role-param / mcp-policy-param )
mcp-sel-param     =  generic-param
mcp-role-param    =  "role" EQUAL DQUOTE token DQUOTE
mcp-policy-param  =  "policy" EQUAL DQUOTE token DQUOTE

; Feature-capability indicators (names only; values per RFC 6809):
; +mcp, +mcp.ver, +mcp.cap
~~~

# Examples

## REGISTER with Contact Feature-Caps

~~~
REGISTER sip:example.com SIP/2.0
Via: SIP/2.0/TLS ua.example;branch=z9hG4bK1
From: "Alice" <sip:alice@example.com>;tag=9fxced76sl
To: <sip:alice@example.com>
Call-ID: reg-12345@example.com
CSeq: 4711 REGISTER
Contact: <sip:alice@ua.example>;expires=3600; +mcp; +mcp.ver="1.0";
  +mcp.cap="summarize@2,sql.query@1,urn:ex:doc:1"
Supported: path, outbound, gruu, mcp
Content-Length: 0
~~~

## INVITE with MCP Offer

~~~
INVITE sip:bot@example.com SIP/2.0
Via: SIP/2.0/TLS ua.example;branch=z9hG4bK2
From: "Alice" <sip:alice@example.com>;tag=83
To: <sip:bot@example.com>
Call-ID: call-abc@example.com
CSeq: 1 INVITE
Supported: replaces, timer, mcp
Content-Type: application/mcp+json
Content-Length: 192

{
  "mcp_version": "1.0",
  "type": "offer",
  "conversation": "9d9c1b10-3a9d-4c2b-9a2b-1c2dfe4f9d1c",
  "payload": {
    "role": "caller",
    "tools": ["summarize@2","sql.query@1"],
    "schemas": ["urn:ex:doc:1"]
  }
}
~~~

~~~
SIP/2.0 200 OK
Via: SIP/2.0/TLS ua.example;branch=z9hG4bK2
From: "Alice" <sip:alice@example.com>;tag=83
To: <sip:bot@example.com>;tag=99
Call-ID: call-abc@example.com
CSeq: 1 INVITE
Supported: mcp
Content-Type: application/mcp+json
Content-Length: 172

{
  "mcp_version": "1.0",
  "type": "answer",
  "conversation": "9d9c1b10-3a9d-4c2b-9a2b-1c2dfe4f9d1c",
  "payload": {
    "role": "callee",
    "tools": ["summarize@2"],
    "schemas": ["urn:ex:doc:1"]
  }
}
~~~

## Mid-Dialog MCP MESSAGE (native JSON‑RPC)

~~~
MESSAGE sip:bot@example.com;gr=xyz SIP/2.0
Via: SIP/2.0/TLS ua.example;branch=z9hG4bK3
From: "Alice" <sip:alice@example.com>;tag=83
To: <sip:bot@example.com>;tag=99
Call-ID: call-abc@example.com
CSeq: 2 MESSAGE
Content-Type: application/mcp+json
Content-Length: 144

{
  "jsonrpc": "2.0",
  "id": 101,
  "method": "tools/call",
  "params": {"name":"summarize","arguments":{"text":"..."}}
}
~~~

## SDP Offer: Audio (SRTP) + MSRP (msrps) for MCP

~~~
v=0
o=alice 2890844526 2890844526 IN IP4 ua.example.com
s=-
c=IN IP4 ua.example.com
t=0 0
m=audio 49170 UDP/TLS/RTP/SAVP 111 0
a=rtpmap:111 opus/48000/2
a=fmtp:111 minptime=10;useinbandfec=1
a=rtpmap:0 PCMU/8000
a=setup:actpass
a=sendrecv
m=message 2855 TCP/TLS/MSRP *
a=setup:actpass
a=connection:new
a=path:msrps://ua.example.com:2855/iau39;tcp
a=accept-types: application/mcp+json
a=sendrecv
~~~

## MSRP SEND carrying application/mcp+json

~~~
MSRP a786hjs2 SEND
To-Path: msrps://bob.example.com:7394/iau39;tcp
From-Path: msrps://ua.example.com:2855/iau39;tcp
Message-ID: 87652
Byte-Range: 1-172/172
Success-Report: yes
Failure-Report: yes
Content-Type: application/mcp+json

{
  "jsonrpc": "2.0",
  "id": 42,
  "method": "speech/event",
  "params": {"type":"vad_start","media":{"mid":"0","rtp_ts":367128000}}
}
-------a786hjs2$
~~~

# Security Considerations

This section provides comprehensive security analysis as required for IETF specifications. The combination of AI capabilities (MCP) with network signaling (SIP) creates unique security considerations that require careful analysis and mitigation.

## Transport Security

**Mandatory TLS Usage:**
- All SIP signaling carrying MCP content MUST use TLS (SIPS)
- TLS version MUST be 1.2 or higher with forward secrecy
- Certificate validation MUST follow {{RFC5922}} (SIP TLS)
- MSRP sessions MUST use MSRPS (TLS-protected MSRP)
- WebSocket connections MUST use WSS (WebSocket Secure)

**Certificate Management:**
- Agents MUST validate peer certificates against trusted CAs
- Certificate pinning SHOULD be used for known agent relationships
- Certificate revocation checking MUST be implemented
- Mutual TLS authentication SHOULD be used for high-security deployments

## Authentication and Authorization

**Agent Authentication:**
- SIP Digest authentication MUST be supported as baseline
- Certificate-based authentication SHOULD be preferred
- Multi-factor authentication MAY be required for sensitive agents
- Agent identity MUST be cryptographically bound to capabilities

**Capability Authorization:**
- MCP capabilities MUST be authorized per peer relationship
- Least-privilege principle MUST govern capability advertisement
- Dynamic capability restriction MUST be supported
- Tool execution MUST require explicit authorization

## Content Protection

**Payload Integrity:**
- MCP payloads SHOULD use digital signatures for integrity
- S/MIME MAY be used for end-to-end payload protection
- JSON-RPC message IDs MUST be cryptographically secure
- Replay protection MUST be implemented using nonces/timestamps

**Content Validation:**
- All MCP payloads MUST be validated against JSON schema
- Tool parameters MUST be sanitized and validated
- Payload size limits MUST be enforced (recommend 1MB default)
- Malformed payloads MUST be rejected with appropriate SIP errors

# IANA Considerations

This document requests IANA registration of SIP protocol elements as described below. As an Informational RFC, these registrations follow the Designated Expert review process per {{RFC5727}}.

## Registration of Option-Tag

Per {{RFC5727}}, SIP option tags require Standards Action for registration. This Informational specification does not request registration of the "mcp" option tag. Implementations using this specification SHOULD use an experimental or private option tag (e.g., "x-mcp" or organization-specific variants) until a Standards Track specification is available.

## Registration of Header Fields

The following header fields are requested for registration under the Designated Expert review process per {{RFC5727}}:

* **Header Field Name:** MCP-Capabilities  
* **Compact Form:** none  
* **Reference:** This document  
* **Registration Type:** Informational (Designated Expert Review)

* **Header Field Name:** MCP-Select  
* **Compact Form:** none  
* **Reference:** This document  
* **Registration Type:** Informational (Designated Expert Review)

## Registration of Feature-Capability Indicators

The following feature-capability indicators are requested for registration:

* **Indicator:** +mcp  
* **Reference:** This document  
* **Registration Type:** Informational (Designated Expert Review)

* **Indicator:** +mcp.ver  
* **Reference:** This document  
* **Registration Type:** Informational (Designated Expert Review)

* **Indicator:** +mcp.cap  
* **Reference:** This document  
* **Registration Type:** Informational (Designated Expert Review)

## Media Type Registration

This document requests registration of the following media type:

**Type name:** application  
**Subtype name:** mcp+json  
**Required parameters:** none  
**Optional parameters:** charset (defaults to UTF-8)  
**Encoding considerations:** binary; typically UTF-8 JSON  
**Security considerations:** see Section 10  
**Interoperability considerations:** none  
**Published specification:** This document  
**Applications that use this media type:** SIP UAs implementing MCP extension  
**Fragment identifier considerations:** n/a  
**Additional information:** n/a  
**Person & email to contact for further information:** [Author contact information]  
**Intended usage:** LIMITED USE (see Applicability Statement in Section 3.1)  
**Restrictions on usage:** See Section 3.1 for deployment limitations  
**Author:** Thomas McCarthy-Howe  
**Change controller:** IETF

--- back

# Acknowledgments

Thanks to the SIP and ART area reviewers for early feedback.

# Change Log

- **-00** Initial version; added Section 2 introducing MCP; added Section 7.5
  on multimodal operation and Examples 9.4–9.5; added Section 4.1 on
  agent‑to‑agent interoperation with two use cases.