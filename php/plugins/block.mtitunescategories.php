<?php
function smarty_block_mtitunescategories($args, $content, &$ctx, &$repeat) {
    $localvars = array('_itunescats', 'itunescat');
    $counter = 0;

    if (!isset($content)) {
        $ctx->localize($localvars);
        $blog_id = $ctx->stash('blog_id');
        $args['blog_id'] = $ctx->stash('blog_id');
	$db = $ctx->mt->db;
	$cfg = $db->fetch_plugin_config('Podcast', 'blog:' . $blog_id);
	$cats = $cfg['itunes-category'];
	if (!is_array($cats)) {
          $cats = array($cats);
        }
        $ctx->stash('_itunescats', $cats);
    } else {
        $cats = $ctx->stash('_itunescats');
        $counter = $ctx->stash('_itunescats_counter');
    }

    if ($counter < count($cats)) {
        $cat = $cats[$counter];
        $ctx->stash('_itunes_category',  $cat);
        $ctx->stash('_itunescats_counter', $counter + 1);

        $repeat = true;
        $count = $counter + 1;
        $ctx->__stash['vars']['__counter__'] = $count;
        $ctx->__stash['vars']['__odd__'] = ($count % 2) == 1;
        $ctx->__stash['vars']['__even__'] = ($count % 2) == 0;
        $ctx->__stash['vars']['__first__'] = $count == 1;
        $ctx->__stash['vars']['__last__'] = ($count == count($cats));
    } else {
        $ctx->restore($localvars);
        $repeat = false;
    }

    return $content;
}
?>

