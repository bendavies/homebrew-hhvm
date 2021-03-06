require 'formula'

class Jemallocfb < Formula
  homepage 'http://www.canonware.com/jemalloc/download.html'
  url 'http://www.canonware.com/download/jemalloc/jemalloc-3.4.1.tar.bz2'
  sha1 '9d5697a5601ddcd7183743588231b1323707737f'

  keg_only "We're just a patched version."

  # __GLIBC__ is not defined, but we still want hooks!
  def patches
    DATA
  end

  def install
    # don't use a prefix
    system './configure', '--disable-debug', "--prefix=#{prefix}", "--with-jemalloc-prefix="
    system 'make install'

    # This otherwise conflicts with google-perftools
    mv "#{bin}/pprof", "#{bin}/jemalloc-pprof"
  end
end

__END__
diff --git a/src/jemalloc.c b/src/jemalloc.c
index bc350ed..8959959 100644
--- a/src/jemalloc.c
+++ b/src/jemalloc.c
@@ -1312,7 +1312,6 @@ je_valloc(size_t size)
 #define        is_malloc_(a) malloc_is_ ## a
 #define        is_malloc(a) is_malloc_(a)

-#if ((is_malloc(je_malloc) == 1) && defined(__GLIBC__) && !defined(__UCLIBC__))
 /*
  * glibc provides the RTLD_DEEPBIND flag for dlopen which can make it possible
  * to inconsistently reference libc's malloc(3)-compatible functions
@@ -1325,6 +1324,7 @@ je_valloc(size_t size)
 JEMALLOC_EXPORT void (* __free_hook)(void *ptr) = je_free;
 JEMALLOC_EXPORT void *(* __malloc_hook)(size_t size) = je_malloc;
 JEMALLOC_EXPORT void *(* __realloc_hook)(void *ptr, size_t size) = je_realloc;
+#ifdef JEMALLOC_OVERRIDE_MEMALIGN
 JEMALLOC_EXPORT void *(* __memalign_hook)(size_t alignment, size_t size) =
     je_memalign;
 #endif