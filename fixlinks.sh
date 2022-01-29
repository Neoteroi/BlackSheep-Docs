echo "Fixing links..."

for i in ./site/*.html
do
  echo "Fixing $i"
  sed -i -E 's,href="\.\.?",href="/blacksheep/",' $i
  sed -i -E 's,base: ".",base: "/blacksheep/",' $i
  sed -i -E 's,worker: "assets/,worker: "/blacksheep/assets/,' $i
  sed -i -E 's,src="\.\/([a-z]+),src="/blacksheep/\1,' $i
  sed -i -E 's,href="\.\/([a-z]+),href="/blacksheep/\1,' $i
  sed -i -E 's,src="([a-z]+),src="/blacksheep/\1,' $i
  sed -i -E 's,href="([a-z]+),href="/blacksheep/\1,' $i
  sed -i -E 's,src="([a-z]+),src="/blacksheep/\1,' $i
  sed -i -E 's,src="img/,src="/blacksheep/img/,' $i
  sed -i -E 's,src="../,src="/blacksheep/,' $i
  sed -i -E 's,href="../,href="/blacksheep/,' $i
  sed -i -E 's,href="css/,href="/blacksheep/css/,' $i
  sed -i -E 's,href="img/,href="/blacksheep/img/,' $i
  sed -i -E 's,href="assets/,href="/blacksheep/assets/,' $i
  sed -i -E 's,/blacksheep/https://,https://,' $i
  sed -i -E 's,src="/img,src="/blacksheep/img,' $i
done


for i in ./site/**/*.html
do
  echo "Fixing $i"
  sed -i -E 's,href="\.\.?",href="/blacksheep/",' $i
  sed -i -E 's,base: "\.\.",base: "/blacksheep/",' $i
  sed -i -E 's,worker: "\.\./assets/,worker: "/blacksheep/assets/,' $i
  sed -i -E 's,src="\.\/([a-z]+),src="/blacksheep/\1,' $i
  sed -i -E 's,href="\.\/([a-z]+),href="/blacksheep/\1,' $i
  sed -i -E 's,src="([a-z]+),src="/blacksheep/\1,' $i
  sed -i -E 's,href="([a-z]+),href="/blacksheep/\1,' $i
  sed -i -E 's,src="([a-z]+),src="/blacksheep/\1,' $i
  sed -i -E 's,src="img/,src="/blacksheep/img/,' $i
  sed -i -E 's,src="../,src="/blacksheep/,' $i
  sed -i -E 's,href="../,href="/blacksheep/,' $i
  sed -i -E 's,href="css/,href="/blacksheep/css/,' $i
  sed -i -E 's,href="img/,href="/blacksheep/img/,' $i
  sed -i -E 's,href="assets/,href="/blacksheep/assets/,' $i
  sed -i -E 's,src="/img,src="/blacksheep/img,' $i
  sed -i -E 's,/blacksheep/https://,https://,' $i
done

for i in ./site/**/*.html
do
  echo "Fixing $i"
  sed -i -E 's,/blacksheep/https://,https://,' $i
  sed -i -E 's,/blacksheep/http://,http://,' $i
done
