#!/usr/bin/env bash
# T-PUBSKILL01 · Send email via LiteStartup (does NOT go through git).
#
# Default: notification endpoint (no custom domain needed, scope: notification)
# With --from: custom domain email endpoint (scope: email)
#
# Usage:
#   ls-send-email.sh --to=<email> --subject=<subject> --body=<body>
#   ls-send-email.sh --from=<email> --to=<email> --subject=<subject> --body=<body>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../shared/_lib.sh"

# Parse arguments
FROM=""
TO=""
SUBJECT=""
BODY=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --from=*) FROM="${1#*=}"; shift ;;
        --to=*) TO="${1#*=}"; shift ;;
        --subject=*) SUBJECT="${1#*=}"; shift ;;
        --body=*) BODY="${1#*=}"; shift ;;
        *) shift ;;
    esac
done

if [ -z "$SUBJECT" ]; then
    ls_error "Missing --subject"
fi

if [ -z "$BODY" ]; then
    ls_error "Missing --body"
fi

if [ -n "$FROM" ]; then
    # Custom domain email endpoint (requires 'email' scope)
    if [ -z "$TO" ]; then
        ls_error "Missing --to (required when using --from)"
    fi
    echo "Sending email from ${FROM} to ${TO}..."
    PAYLOAD=$(python3 -c "
import json, sys
print(json.dumps({
    'from': sys.argv[1],
    'to': [sys.argv[2]],
    'subject': sys.argv[3],
    'content': sys.argv[4]
}))
" "$FROM" "$TO" "$SUBJECT" "$BODY")
    RESPONSE=$(ls_api POST "/client/v2/emails" "$PAYLOAD")
else
    # Notification endpoint (default, requires 'notification' scope)
    echo "Sending notification${TO:+ to ${TO}}..."
    PAYLOAD=$(python3 -c "
import json, sys
d = {'subject': sys.argv[1], 'content': sys.argv[2]}
if sys.argv[3]:
    d['to'] = sys.argv[3]
print(json.dumps(d))
" "$SUBJECT" "$BODY" "$TO")
    RESPONSE=$(ls_api POST "/client/v2/emails/notification" "$PAYLOAD")
fi

ls_ok "Email sent"
echo "$RESPONSE"
