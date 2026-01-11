# Discord Post Draft - Mojo Community Help

**Copy the text below to post in the Modular Discord #mojo channel:**

---

**Seeking Guidance: Dict Iterator Pattern for Building Nested Structures**

Hi Mojo community! I'm relatively new to Mojo and building a native TOML parser as a learning project ([GitHub](https://github.com/DataBooth/mojo-toml)). I've hit what seems like a Dict iteration limitation and would love guidance on the right pattern to use.

**What I'm Trying To Do:**
Parse TOML files with table headers and build nested Dict structures:
```toml
[database]
host = "localhost"
```
→ Should create `{"database": {"host": "localhost"}}`

**The Problem:**
I need to iterate Dict entries to copy/build nested structures, but can't access the entries:

```mojo
for entry in dict.items():
    var key = entry[].key     // ❌ Error: DictEntry is not subscriptable
    var val = entry[].value   // ❌ Error: not subscriptable
```

**What I've Tried:**
- Using `.keys()` iterator → same subscripting issue
- Get-modify-put pattern → requires iteration to copy
- Multiple architectural approaches → all hit the same wall

**Current Status:**
✅ Arrays and inline tables work great (71 tests passing)
❌ Blocked on table headers due to this iteration issue

**Question:**
Is there a recommended pattern for iterating Dict entries to build new structures? Or am I approaching this wrong for Mojo's ownership model?

Full technical details and attempted approaches: [TABLE_HEADERS_BLOCKER.md](https://github.com/DataBooth/mojo-toml/blob/main/docs/TABLE_HEADERS_BLOCKER.md)

Any guidance appreciated! Still learning Mojo's patterns. 🔥

---

**Notes for posting:**
- Adjust the GitHub link if your repo URL is different
- Feel free to add @mentions if you know specific Mojo experts
- Consider posting in #help channel if #mojo is very busy
