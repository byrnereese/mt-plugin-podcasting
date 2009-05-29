# Podcast Movable Type Plugin
# This software is licensed under the GPL
# Copyright (C) 2007, Six Apart, Ltd.

package Podcast::CMS;

use strict;
use base qw( MT::App );

sub plugin {
    return MT->component('Podcast');
}

sub id { 'podcast_cms' }

sub init {
    my $app = shift;
    my %param = @_;
    return $app->error($@) if $@;
    $app;
}

sub _discover {
    my ($link, $opts) = @_;
    use LWP::UserAgent;
    my $ua = LWP::UserAgent->new();
    # Create a request
    my $url = $link;
    my $req = HTTP::Request->new(HEAD => $link);
   
    if ($opts->{username}) {
	$url =~ s/https?:\/\/([^\/]*)/\1/i;
	$req->authorization_basic($opts->{username}, $opts->{password}); 
    }

    # Pass request to the user agent and get a response back
    my $res = $ua->request($req);
    if ($res->is_success) {
	my ($fname) = ($link =~ /([^\/]*)$/);
	if ($res->content_type =~ /^audio\//) {
	    return {
		code => $res->code,
		href => $link,
		type => $res->content_type,
		title => "$fname",
		length => $res->content_length,
	    };
	}
    } else {
	return { code => $res->code };
    }

}

sub find {
    my $app = shift;
    my $q = $app->{query};
    my $blog = $app->blog;
    my $tmpl = $app->load_tmpl('dialog/find.tmpl');
    $tmpl->param(blog_id      => $blog->id);
    return $app->build_page($tmpl);
}

sub asset_options {
    my $app = shift;
    init($app);
    my $q = $app->{query};
    my $blog = $app->blog;
    my $url = $q->param('podcast_url');
    my $opts = {
	username => $q->param('username'),
	password => $q->param('password'),
    };
    my $pod;
    eval {
	$pod = _discover( $url, $opts );
    };
    if ($@) {
	MT->log({ message => "Failed to detect podcast properties: $@", blog_id => $app->blog->id });
	return $app->error("Failed to detect podcast properties: $@");
    }
    if ($pod->{code} =~ /40[01]/) {
	my $tmpl = $app->load_tmpl('dialog/auth.tmpl');
	$tmpl->param(blog_id      => $blog->id);
	$tmpl->param(podcast_url  => $url);
	$tmpl->param(auth_failed  => 1)
	    if ($pod->{code} eq "400");
	return $app->build_page($tmpl);

    } elsif ($pod->{code} eq "403") {
	my $tmpl = $app->load_tmpl('dialog/auth.tmpl');
	$tmpl->param(blog_id      => $blog->id);
	$tmpl->param(podcast_url  => $url);
	$tmpl->param(auth_failed  => 1);
	return $app->build_page($tmpl);

    } elsif ($pod->{code} eq "404") {
	my $tmpl = $app->load_tmpl('dialog/find.tmpl');
	$tmpl->param(blog_id      => $blog->id);
	$tmpl->param(podcast_url  => $url);
	$tmpl->param(notfound     => 1);
	return $app->build_page($tmpl);

    } elsif (!$pod) {
	return $app->error("No file found at URL: $url");
    }
    require MT::Asset::Podcast;
    my $asset = MT::Asset::Podcast->new;
    $asset->blog_id($q->param('blog_id'));
    $asset->label($pod->{title});
    $asset->content_length($pod->{length});
    $asset->mime_type($pod->{type});
    $asset->url($url);
    $asset->created_by( $app->user->id );
    $asset->duration($q->param('duration'));
    $asset->subtitle($q->param('subtitle'));
    my $original = $asset->clone;
    $asset->save;

    $app->run_callbacks( 'cms_post_save.asset', $app, $asset, $original );
    return $app->complete_insert( 
        asset       => $asset,
	is_podcast  => 1,
    );
}

1;

__END__
