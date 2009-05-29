# Podcast Movable Type Plugin
# This software is licensed under the GPL
# Copyright (C) 2008, Six Apart, Ltd.

package Podcast::Plugin;

use strict;

use Carp qw( croak );
#use MT::Util qw( relative_date offset_time offset_time_list epoch2ts ts2epoch format_ts );


sub dialog_mod {
    my ($cb, $app, $html_ref) = @_;

    my $html = <<"EOF";
    <mtapp:setting
        id="duration"
        label_class="top-label"
        label="<__trans phrase="Duration">">
            <div class="textarea-wrapper">
                <input type="text" name="duration" value="<mt:var name="subtitle" escape="html">">
            </div>
    </mtapp:setting>
    <mtapp:setting
        id="summary"
        label_class="top-label"
        label="<__trans phrase="Subtitle">">
            <div class="textarea-wrapper">
                <input type="text" name="subtitle" value="<mt:var name="subtitle" escape="html">" class="full-width">
            </div>
    </mtapp:setting>
EOF
    $$html_ref =~ s{(<mtapp:setting\s+id="file_desc")}{$html $1}xmsg;

    $html = <<"EOF";
    <mtapp:setting
              id="explicit"
              label="<__trans phrase="Does this podcast contain explicit material?">"
              label_class="no-header"
              hint=""
              show_hint="0">
            <input type="checkbox" name="explicit" id="explicit" value="1" checked="checked" />
            <label for="explicit"><__trans phrase="Contains explicit material"></label>
            &nbsp;&nbsp;
            <input type="checkbox" name="block" id="block" value="1" checked="checked" />
            <label for="block"><__trans phrase="Block from being listed in iTunes"></label>
    </mtapp:setting>
EOF
    $$html_ref =~ s{(<mtapp:setting\s+id="file_tags".*?</mtapp:setting>)}{$1 $html}xmsg;

    $$html_ref =~ s{Description}{Summary}xmsg;
    $$html_ref =~ s{File Options}{Podcast Options}xmsg;
    $$html_ref =~ s{Tags}{Keywords}xmsg;
    $$html_ref =~ s{Name}{Title}xmsg;

    return $$html_ref;
}

sub _hdlr_iTunesArtist {
    my ($ctx, $args, $cond) = @_;
    my $blog = $ctx->stash('blog');
    my $plugin = MT->component('Podcast');
    return $plugin->get_config_value('itunes-author', 'blog:' . $blog->id);
}
sub _hdlr_iTunesSubtitle {
    my ($ctx, $args, $cond) = @_;
    my $blog = $ctx->stash('blog');
    my $plugin = MT->component('Podcast');
    return $plugin->get_config_value('itunes-subtitle', 'blog:' . $blog->id);
}
sub _hdlr_iTunesSummary {
    my ($ctx, $args, $cond) = @_;
    my $blog = $ctx->stash('blog');
    my $plugin = MT->component('Podcast');
    return $plugin->get_config_value('itunes-summary', 'blog:' . $blog->id);
}
sub _hdlr_iTunesOwnerName {
    my ($ctx, $args, $cond) = @_;
    my $blog = $ctx->stash('blog');
    my $plugin = MT->component('Podcast');
    return $plugin->get_config_value('itunes-owner-name', 'blog:' . $blog->id);
}
sub _hdlr_iTunesOwnerEmail {
    my ($ctx, $args, $cond) = @_;
    my $blog = $ctx->stash('blog');
    my $plugin = MT->component('Podcast');
    return $plugin->get_config_value('itunes-owner-email', 'blog:' . $blog->id);
}
sub _hdlr_iTunesCategoryName {
    my ($ctx, $args, $cond) = @_;
    return $ctx->stash('_itunes_category');
}
sub _hdlr_HasiTunesCategory {
    my ($ctx, $args, $cond) = @_;
    my $blog = $ctx->stash('blog') || MT->instance->blog;
    my $plugin = MT->component('Podcast');
    my $cats = $plugin->get_config_value('itunes-category', 'blog:' . $blog->id);
    if (ref($cats) eq '') { $cats = [ $cats ]; } 
    elsif (ref($cats) ne 'ARRAY') { push(@$cats,$cats); }
    foreach (@$cats) {
	return 1 if ($_ eq $args->{category});
    }
    return 0;
}
sub _hdlr_iTunesCategories {
    my ($ctx, $args, $cond) = @_;
    my $out = "";
    my $blog = $ctx->stash('blog');
    my $plugin = MT->component('Podcast');
    my $cats = $plugin->get_config_value('itunes-category', 'blog:' . $blog->id);
    if (ref($cats) ne 'ARRAY') { push(@$cats,$cats); }
    foreach my $cat (@$cats) {
	$ctx->stash("_itunes_category",$cat);
	defined(my $txt = $ctx->slurp($args,$cond)) or return;
	$out .= $txt;
    }
    return $out;
}

1;

__END__
