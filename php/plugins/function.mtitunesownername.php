<?php
function smarty_function_mtitunesownername($args, &$ctx) {
  $db = $ctx->mt->db;
  $blog = $ctx->stash('blog');
  $blog_id = $blog['blog_id'];
  $cfg = $db->fetch_plugin_config('Podcast', 'blog:' . $blog_id);
  return $cfg['itunes-owner-name'];
}
?> 
