@ColorAboutPage = React.createClass
  render : ->
    content = `<span>
      <section>
        <h1>about</h1>
        <p>Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.</p>
        <p>Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?</p>
      </section>
    </span>`

    rightGutter = `<span>
      <section>
        <h3>get the book</h3>
        <p>you can purchase a physical or digital editon of the book “What Color Is My Internet?” by Greg Leuch on <a href="#">Lulu</a> or <a href="#">Amazon</a>.</p>
        <ul className="buttons">
          <li><a href="#" className="btn btn-default btn-lulu">buy on lulu</a></li>
          <li><a href="#" className="btn btn-default btn-amazon">buy on amazon</a></li>
        </ul>
        <p>PDF versions are available for free on the <a href="#">LINK Center for the Arts of the Information Age</a> website.</p>
      </section>
    </span>`

    `<ColorStaticPageDisplay content={content} rightGutter={rightGutter} pageName="about" />`
