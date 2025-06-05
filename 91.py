import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse, parse_qs, urlencode
import os
import re
from concurrent.futures import ThreadPoolExecutor, as_completed
import time

class ForumScraper:
    def __init__(self):
        self.session = requests.Session()
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept-Language': 'en-US,en;q=0.9'
        }
        self.request_delay = 1  # 初始延迟1秒
        self.last_request_time = 0
        self.cache = {}

    def get_page_content(self, url):
        # 缓存检查
        if url in self.cache:
            return self.cache[url]
        
        # 请求速率控制
        elapsed = time.time() - self.last_request_time
        if elapsed < self.request_delay:
            time.sleep(self.request_delay - elapsed)
        
        try:
            response = self.session.get(url, headers=self.headers, timeout=5)
            response.raise_for_status()
            response.encoding = response.apparent_encoding
            content = response.text
            
            # 更新缓存
            self.cache[url] = content
            self.last_request_time = time.time()
            
            # 动态调整延迟 - 如果响应快就减少延迟
            response_time = time.time() - self.last_request_time
            if response_time < 0.5 and self.request_delay > 0.5:
                self.request_delay *= 0.9
            elif response_time > 2:
                self.request_delay *= 1.1
            
            return content
        except requests.RequestException as e:
            print(f"[!] 无法访问页面 {url}: {e}")
            # 出错时增加延迟
            self.request_delay = min(self.request_delay * 1.5, 5)
            return None

    def parse_posts(self, page_content, base_url, target_author):
        if not page_content:
            return []
        
        soup = BeautifulSoup(page_content, 'lxml')  # 使用lxml解析器，速度更快
        posts = []
        
        # 更精确的选择器
        thread_rows = soup.select('tbody[id^="normalthread"]')
        
        for row in thread_rows:
            # 尝试直接定位作者元素
            author_tag = row.select_one('td.by cite a, td.author cite a, a[href*="member.php"]')
            if not author_tag:
                continue
                
            author = author_tag.text.strip()
            
            # 尝试直接定位标题链接
            title_tag = row.select_one('th a.s.xst, th a[href*="thread"]')
            if not title_tag or not title_tag.get('href'):
                continue
                
            title_link = urljoin(base_url, title_tag['href'])
            
            if author.lower() == target_author.lower():
                posts.append((author, title_link))
        
        return posts

    def save_to_txt(self, posts, target_author):
        if not posts:
            return
        
        safe_filename = re.sub(r'[\\/*?:"<>|]', "", target_author).strip() + ".txt"
        with open(safe_filename, 'w', encoding='utf-8') as f:
            for _, link in posts:
                f.write(f"{link}\n")
        print(f"[+] 已为作者 '{target_author}' 保存 {len(posts)} 个帖子链接到 {safe_filename}")

    def construct_page_url(self, base_url, page):
        parsed_url = urlparse(base_url)
        query_params = parse_qs(parsed_url.query)
        query_params['page'] = [str(page)]
        new_query = urlencode(query_params, doseq=True)
        return f"{parsed_url.scheme}://{parsed_url.netloc}{parsed_url.path}?{new_query}"

    def scrape_author_posts(self, base_url, target_author, pages):
        all_posts = []
        
        # 使用线程池并发获取页面
        with ThreadPoolExecutor(max_workers=5) as executor:
            futures = []
            for page in range(1, pages + 1):
                url = self.construct_page_url(base_url, page)
                futures.append(executor.submit(self.fetch_and_parse_page, url, base_url, target_author))
            
            for future in as_completed(futures):
                posts = future.result()
                if posts:
                    all_posts.extend(posts)
        
        return all_posts

    def fetch_and_parse_page(self, url, base_url, target_author):
        print(f"[+] 正在爬取页面: {url}")
        page_content = self.get_page_content(url)
        if page_content and target_author.lower() in page_content.lower():
            print(f"[+] 页面包含作者 '{target_author}'")
        return self.parse_posts(page_content, base_url, target_author.lower())

def main():
    scraper = ForumScraper()
    base_url = "https://t0408.btc760.com/forumdisplay.php?fid=33&page=1"
    
    target_author = input("请输入要爬取的目标作者名称: ").strip()
    if not target_author:
        print("[!] 作者名称不能为空！")
        return
    
    while True:
        try:
            pages = int(input("请输入需要爬取的页数 (1-9999999): "))
            if 1 <= pages <= 9999999:
                break
            print("[!] 请输入1到9999999之间的数字！")
        except ValueError:
            print("[!] 请输入有效的数字！")
    
    start_time = time.time()
    all_posts = scraper.scrape_author_posts(base_url, target_author, pages)
    
    if all_posts:
        scraper.save_to_txt(all_posts, target_author)
    else:
        print(f"[-] 未找到作者 '{target_author}' 的任何帖子信息！")
    
    print(f"[+] 爬取完成，耗时 {time.time() - start_time:.2f} 秒")

if __name__ == "__main__":
    main()