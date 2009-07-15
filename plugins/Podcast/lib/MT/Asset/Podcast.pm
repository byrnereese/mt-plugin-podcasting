# Copyright 2001-2008 Six Apart. This code cannot be redistributed without
# permission from www.sixapart.com.  For more information, consult your
# Movable Type license.
#
# $Id: $

package MT::Asset::Podcast;

use strict;
use base qw( MT::Asset );

__PACKAGE__->install_properties( { class_type => 'podcast', } );
__PACKAGE__->install_meta( { columns => [ 
				 'content_length',
				 'duration',
				 'subtitle',
				 'explicit',
				 'block',
				 ], } );

sub class_label { MT->translate('Podcast'); }
sub class_label_plural { MT->translate('Podcasts'); }
sub file_name { my $asset   = shift; return $asset->label; }
sub file_path { my $asset   = shift; return undef; }
sub has_thumbnail { 0; }

sub as_html {
    my $asset   = shift;
    my $app = MT->instance;
    my ($param) = @_;
    my $text = '';
    my $path = $app->{cfg}->StaticWebPath;
    if ($path !~ /\/$/) { $path .= '/'; }
    if ($param->{'use_player'}) { 
	$text = sprintf(
			'<embed src="%splugins/Podcast/mp3player.swf" width="320" height="20" allowfullscreen="true" allowscriptaccess="always" flashvars="&file=%s&height=20&width=320" />',
			$path,
			$asset->url,
			);
    } else {
	$text = sprintf(
			'<a href="%s">%s</a>',
			$asset->url,
			$asset->label,
			);
    }
    return $asset->enclose($text);
}

sub on_upload {
    my $asset = shift;
    my ($param) = @_;
    $asset->subtitle($param->{subtitle});
    $asset->duration($param->{duration});
    $asset->explicit($param->{explicit});
    $asset->block($param->{block});
    $asset->save;
}

sub insert_options {
    my $asset = shift;
    my ($param) = @_;

    my $app   = MT->instance;
    my $perms = $app->{perms};
    my $blog  = $asset->blog or return;

    $param->{thumbnail}  = $asset->thumbnail_url;
    $param->{video_id}   = 1;
    $param->{align_left} = 1;
    $param->{html_head} = '<link rel="stylesheet" href="'.$app->static_path.'plugins/Podcast/styles/app.css" type="text/css" />';
    return $app->build_page( '../plugins/Podcast/tmpl/dialog/podcast_options.tmpl', $param );
}

1;
__END__

=head1 NAME

MT::Asset::Podcast

=head1 AUTHOR & COPYRIGHT

Please see the L<MT/"AUTHOR & COPYRIGHT"> for author, copyright, and
license information.

=cut
