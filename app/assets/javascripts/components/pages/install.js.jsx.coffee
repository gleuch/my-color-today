@ColorInstallPage = React.createClass
  render : ->
    content = `<span>
      <section>
        <h1>install</h1>
        <p>Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.</p>
        <ul className="buttons">
          <li key="chrome">
            <a className="btn btn-default btn-lg btn-google" target="_blank" href="https://chrome.google.com/webstore/detail/nkghbibhhebkddaeebapfkooljjfhnca">get for google chrome</a>
          </li>
        </ul>
      </section>
    </span>`

    `<ColorStaticPageDisplay content={content} pageName="about" />`
