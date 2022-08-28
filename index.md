---
title: "Blogging with GitHub Pages"
---

This space will be filled by some thoughts on DevOps, tips on CLI stuff, and other contents

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.date | date: "%Y-%m-%d"}} - {{ post.title }}</a>
    </li>
  {% endfor %}
</ul>

