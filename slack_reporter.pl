#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use 5.014;

use Encode;
use JSON::PP qw/encode_json decode_json/;
use Sys::Hostname;
use IPC::Open2;

our $version = '0.1';

run();

sub run {
    if (-t STDIN) {
        # show help & variables
        show_help();
        exit 1;
    }

    my $json = do { local $/; <> };

    my $hash = decode_json($json);
    if ($hash->{exitCode} != 0 || !$ENV{SLACK_MUTE_ON_NORMAL}) {
        send_slack($hash);
    }
}

sub send_slack {
    my ($hash, $color) = @_;

    $color //= '#d22a3c'; # red
    my $hostname = hostname();
    my $message = $hash->{exitCode} == 0 ?
        sprintf ':ok: [%s] horenso reports success *%s*', $hostname, $hash->{command}:
        sprintf ':anger: [%s] horenso reports error! %s', $hostname, ($ENV{SLACK_MENTION} // '');

    my $output = $hash->{output};
    if ($ENV{SLACK_PASTEBIN_CMD}) {
        my($write, $read);
        my $pid = open2($read, $write, $ENV{SLACK_PASTEBIN_CMD});
        if ($pid) {
            print $write $output;
            close($write);
            waitpid($pid, 0);
            $output = do { local $/; <$read> };
            close($read);
        }
    }

    my $payload = {
        text       => $message,
        channel    => $ENV{SLACK_CHANNEL} // '#general',
        link_names => 1,
        $ENV{SLACK_USERNAME} ?   (username   => decode_utf8($ENV{SLACK_USERNAME})) : (),
        $ENV{SLACK_ICON_EMOJI} ? (icon_emoji => $ENV{SLACK_ICON_EMOJI}): (),
        $hash->{exitCode} ? (attachments => [ {
            fallback => sprintf("%s %s", $message, $hash->{command}),
            color    => $color,
            fields   => [ {
                title => 'command',
                value => $hash->{command},
            }, {
                title => 'output',
                value => $output,
            } ],
        } ],) : (),
    };

    my $endpoint = $ENV{SLACK_ENDPOINT} // '';

    my $json_text = encode_json($payload);
    # see https://api.slack.com/docs/formatting#how_to_escape_characters
    $json_text =~ s/&/&amp;/g;
    $json_text =~ s/</&lt;/g;
    $json_text =~ s/>/&gt;/g;

    my $form_data = 'payload=' . $json_text;

    system('curl', '-d', $form_data, $endpoint);
}

sub show_help {
    my $mute = $ENV{SLACK_MUTE_ON_NORMAL} ? 'mute' : 'not mute';
    say 'Horenso Slack Reporter v' . $version;
    say 'usage: horenso -r slack_reporter.pl | [your command here]';
    say '';
    say 'To configure script, please set below environment variables.';
    say '  SLACK_ENDPOINT:  set incoming-webhook endpoint (required) e.g. "https://hooks.slack.com/services/...."';
    say '    current value: ' . ($ENV{SLACK_ENDPOINT} // '(not set)');
    say '';
    say '  SLACK_USERNAME: set slackbot username, e.g. "slackbot"';
    say '    current value: ' . ($ENV{SLACK_USERNAME} // '(not set)');
    say '';
    say '  SLACK_ICON_EMOJI:  set slackbot icon_emoji, e.g. ":innocent:"';
    say '    current value: ' . ($ENV{SLACK_ICON_EMOJI} // '(not set)');
    say '';
    say '  SLACK_CHANNEL:  set message channel, e.g. "#general"';
    say '    current value: ' . ($ENV{SLACK_CHANNEL} // '(not set)');
    say '';
    say '  SLACK_MENTION:  set mention account, e.g. "@acidlemon:"';
    say '    current value: ' . ($ENV{SLACK_MENTION} // '(not set)');
    say '';
    say '  SLACK_PASTEBIN_CMD:  set external command to paste output';
    say '    current value: ' . ($ENV{SLACK_PASTEBIN_CMD} // '(not set)');
    say '';
    say '  SLACK_MUTE_ON_NORMAL:  don\'t send message if command finished normally(bool value)';
    say '    current value: ' . ($ENV{SLACK_MUTE_ON_NORMAL} // '') . ' (' . $mute . ')';
    say '';
}
