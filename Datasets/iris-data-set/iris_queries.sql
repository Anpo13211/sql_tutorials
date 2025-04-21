/* Datasets ディレクトリから .sql ファイルを MySQL サーバーに取り込む
docker exec -i <コンテナ名> mysql -u <ユーザー名> -p<パスワード> < /path/to/Datasets/iris.sql

-- 例: 
    docker exec -i test_mysql mysql -u root –psecret_password < /home/anpo13211/iris.sql


もしくは、ファイルをコンテナにコピーしてから実行する

    docker cp /path/to/Datasets/iris.sql <コンテナ名>:/tmp/iris.sql
    docker exec –it <コンテナ名> bash
    mysql -u <ユーザー名> -p<パスワード> < /tmp/iris.sql

-- 例:
    docker cp /home/anpo13211/airport.sql test_mysql:/tmp/iris.sql
    docker ecec –it test_mysql bash
    mysql –u root –psecret_password < /tmp/iris.sql
*/

-- 1. テーブルの概要、スキーマが見たい：
    DESCRIBE iris;

-- 2. テーブルの中身を見たい：
    SELECT * FROM iris;
-- 3. テーブルの中身の一部だけみたい：
    SELECT * FROM iris LIMIT 10;

-- 4. 萼片の長さの平均を知りたい
    SELECT avg(sepal_length_cm)
    FROM iris;
-- 5. setosa の萼片の長さの平均を知りたい
    SELECT avg(sepal_length_cm)
    FROM iris
    WHERE species = 'setosa';

-- 6. 品種ごとに花弁の平均、最大値、最小値を出す：
    SELECT 
    species,
    AVG(petal_length_cm),
    MAX(petal_length_cm),
    MIN(petal_length_cm)
    FROM iris
    GROUP BY species;

-- 7. PARTITION BY を使った場合：
    SELECT DISTINCT species,
    avg(sepal_length_cm) OVER(PARTITION BY species) AS avg_sepal_length_cm
    FROM iris;

-- 8. PARTITION BY を使うと、萼片の平均だけでなくそれぞれの花の萼片の長さも合わせて見たい場合に有効
    SELECT DISTINCT species,
    sepal_length_cm,
    avg(sepal_length_cm) OVER(PARTITION BY species) AS avg_sepal_length_cm
    FROM iris;

/* これを GROUP BY を使うとうまくいかない*/
    -- SELECT DISTINCT species,
    -- sepal_length_cm,
    -- avg(sepal_length_cm) AS avg_sepal_length_cm
    -- FROM iris
    -- GROUP BY species;
-- エラーになる!!

-- 9. 切り捨てした花弁の長さでグループ分けし、降順で並べる
    SELECT floor(petal_length_cm) k, count(*) v
    FROM iris
    GROUP BY k
    ORDER BY v DESC;

-- 10. 花弁の長さが4より大きい行だけを抽出し、数を数える
    SELECT 
    species,
    count(*) AS count
    FROM iris
    WHERE petal_length_cm > 4
    GROUP BY species;

-- 11. 萼片幅の分散と標準偏差を求める
    SELECT
      VAR_POP(sepal_width_cm)   AS variance_sepal_width,
      STDDEV_POP(sepal_width_cm) AS stddev_sepal_width
    FROM iris;

-- 12. 種別ごとのセパル平均と全体平均を一度に見る（WITH ROLLUP）
-- WITH ROLLUP を付けると、最後にグループ全体の合計（この場合は全種の平均）が NULL 行で返ります。
    SELECT 
    species,
    AVG(sepal_length_cm) AS avg_sepal_length,
    AVG(sepal_width_cm)  AS avg_sepal_width
    FROM iris
    GROUP BY species WITH ROLLUP;

-- 13. 種別ごとの個体数と全体に占める割合（％）を小数点以下2桁で表示
    SELECT 
    species,
    COUNT(*) AS cnt,
    ROUND(
        COUNT(*) / (SELECT COUNT(*) FROM iris) * 100,
        2
    ) AS pct_of_total
    FROM iris
    GROUP BY species;

-- 14. 萼片の長さ/花弁の長さ の比率が大きいもの上位5件を抽出
    SELECT 
    species,
    sepal_length_cm,
    petal_length_cm,
    (petal_length_cm / sepal_length_cm) AS ratio
    FROM iris
    WHERE sepal_length_cm > 0
    ORDER BY ratio DESC
    LIMIT 5;

-- 15. 萼片の長さを"SHORT", "MIDDLE", "LONG"に分類
    SELECT
    species,
    sepal_length_cm,
    CASE
        WHEN sepal_length_cm < 5.0    THEN 'SHORT'
        WHEN sepal_length_cm < 6.5    THEN 'MIDDLE'
        ELSE 'LONG'
    END AS sepal_length_category
    FROM iris;

-- 16. 花弁の長さを分類
    SELECT 
    species,
    petal_length_cm,
    CASE
        WHEN petal_length_cm < 2 THEN 'SHORT'
        WHEN petal_length_cm BETWEEN 2 AND 4 THEN 'MIDDLE'
        ELSE 'LONG'
    END AS length_category
    FROM iris;


